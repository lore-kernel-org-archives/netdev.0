From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: MSEC_TO_JIFFIES is messed up...
Date: Wed, 12 May 2004 16:17:52 -0400
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <40A28670.9040308@pobox.com>
References: <20040512020700.6f6aa61f.akpm@osdl.org> <20040512181903.GG13421@kroah.com> <40A26FFA.4030701@pobox.com> <20040512193349.GA14936@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Greg KH <greg@kroah.com>, Andrew Morton <akpm@osdl.org>,
	linux-kernel@vger.kernel.org, Netdev <netdev@oss.sgi.com>
Return-path: <linux-kernel-owner+linux-kernel=40quimby.gnus.org-S265213AbUELUSO@vger.kernel.org>
To: Ingo Molnar <mingo@elte.hu>
In-Reply-To: <20040512193349.GA14936@elte.hu>
List-Id: netdev.vger.kernel.org

Ingo Molnar wrote:
> * Jeff Garzik <jgarzik@pobox.com> wrote:
> 
> 
>>>Woah, that's new.  And wrong.  The code in include/asm-i386/param.h that
>>>says:
>>>	# define JIFFIES_TO_MSEC(x)     (x)
>>>	# define MSEC_TO_JIFFIES(x)     (x)
>>>
>>>Is not correct.  Look at kernel/sched.c for verification of this :)
>>
>>
>>Yes, that is _massively_ broken.
> 
> 
> why is it wrong?


Because drivers define that exact same symbol, in an arch-generic way.

	Jeff
