From: Patrick Simmons <linuxrocks123@netscape.net>
Subject: Re: [PATCH] Experimental new bonding driver mode=batman
Date: Wed, 20 May 2015 18:48:14 -0400
Message-ID: <555D0F2E.90708@netscape.net>
References: <555AD3A7.7050202@netscape.net> <20150519074941.GB17391@unicorn.suse.cz> <555AF479.7000603@netscape.net> <20150520073221.GA19868@unicorn.suse.cz> <10002.1432143933@nyx> <20150520200420.GN9559@gospo.home.greyhouse.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Michal Kubecek <mkubecek@suse.cz>, netdev@vger.kernel.org,
	Veaceslav Falico <vfalico@gmail.com>
To: Andy Gospodarek <gospo@cumulusnetworks.com>,
	Jay Vosburgh <jay.vosburgh@canonical.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from omr-m07.mx.aol.com ([64.12.143.81]:36394 "EHLO
	omr-m07.mx.aol.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754191AbbETWyQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 May 2015 18:54:16 -0400
In-Reply-To: <20150520200420.GN9559@gospo.home.greyhouse.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/20/2015 04:04 PM, Andy Gospodarek wrote:
>
> Well I can now delete most of my initial response.  :)
>
> Overall I would say this is really cool functionality.  Even if you do
> not want it merged, I think it is great that you shared it with the
> community this way.  I got a chance to look at is a bit this morning and
> I agree additional explanation of the algorithm you are using would
> probably be nice for those checking this out for the first time.

Thanks :)  I explained the algorithm in my last email to the list, so I 
won't repeat it here.

>
> I also think if you would be able to leverage the exiting bonding infra
> for using skb->queue_mapping you could probably add the same
> functionality (though it might be higher in the stack), but I totally
> understand if you want to just keep using what you are using as-is.
>
>

I didn't know about the queue_mapping thing.  Thanks for the pointer.

One thing I considered doing that I didn't ultimately do was try to 
implement this as a TUN device.  Userspace coding is always easier and, 
in retrospect, finding some way to manually parse IP and TCP packet 
headers would likely have been trying to debug kernel memory corruption 
bugs.  But another downside would have been that I'm pretty sure all the 
slaves would have had to have been set to promiscuous mode to make it work.

--Patrick Simmons

-- 
If I'm not here, I've gone out to find myself.  If I get back before I 
return, please keep me here.
