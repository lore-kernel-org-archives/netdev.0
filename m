From: Bernard Pidoux F6BVP <f6bvp@free.fr>
Subject: Re: [PATCH][ROSE][AX25] af_ax25: possible circular locking
Date: Sat, 12 Jan 2008 20:48:40 +0100
Message-ID: <47891998.2070802@free.fr>
References: <20071228214857.GA3290@ami.dom.local> <20071229.191443.10947724.davem@davemloft.net> <20071230141323.GA3377@ami.dom.local> <20080110.212242.42433023.davem@davemloft.net> <20080111094005.GA2708@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, ralf@linux-mips.org,
	adobriyan@gmail.com, netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp5-g19.free.fr ([212.27.42.35]:39272 "EHLO smtp5-g19.free.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759256AbYALTso (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 12 Jan 2008 14:48:44 -0500
In-Reply-To: <20080111094005.GA2708@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Jarek Poplawski wrote:
> On Thu, Jan 10, 2008 at 09:22:42PM -0800, David Miller wrote:
>> From: Jarek Poplawski <jarkao2@gmail.com>
>> Date: Sun, 30 Dec 2007 15:13:23 +0100
>>
>>> On Sat, Dec 29, 2007 at 07:14:43PM -0800, David Miller wrote:
> ...
>> I've removed the warning and made the branch back to 'again'
>> unconditional as I think this is the safest version of the
>> change.
>>
>> I'll push this upstream, thanks for fixing this Jarek.
>>
> 
> Thanks for checking this and making safer!
> 
> Regards,
> Jarek P.
> 
> 

I would also like to thank both Jarek and David for this patch.
It is very helpful and probably safe for after killing kissattach
we don't want to use attached ax25 devices.

Regards,

Bernard Pidoux
