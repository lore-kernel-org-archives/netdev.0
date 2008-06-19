From: Bernard Pidoux <bpidoux@free.fr>
Subject: Re: [PATCH] ax25.h unsigned long type for ax25 timers
Date: Fri, 20 Jun 2008 00:38:23 +0200
Message-ID: <485ADFDF.1070509@free.fr>
References: <200806171504.38702.bpidoux@free.fr>	<20080617.223050.266166325.davem@davemloft.net>	<485A893E.4080405@free.fr> <20080619.144621.120746379.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: ralf@linux-mips.org, linux-hams@vger.kernel.org,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-hams-owner@vger.kernel.org>
In-Reply-To: <20080619.144621.120746379.davem@davemloft.net>
Sender: linux-hams-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David,

Your explanation is perfectly clear and I understand the problem now.
Thank you very much for taking the time to explain me that.

Bernard Pidoux




David Miller wrote:
> From: Bernard Pidoux <bpidoux@free.fr>
> Date: Thu, 19 Jun 2008 18:28:46 +0200
> 
>> Unfortunately I don't quite understand exactly why a structure in user 
>> space cannot be changed.
> 
> Because there are userland binaries already compiled out there using
> the current structure layout.  If we change the kernel, those binaries
> stop using a datastructure that matches what the kernel is using.
> Such binaries will break.
> 
> In generic, because of this, you can never change the layout of a
> data structure exported to userland as a kernel interface.
> 
> 
