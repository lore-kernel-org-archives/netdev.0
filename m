From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH] tcp: Generalized TTL Security Mechanism
Date: Thu, 14 Jan 2010 03:04:54 -0800 (PST)
Message-ID: <20100114.030454.16178889.davem@davemloft.net>
References: <20100110220034.4d46ba8a@nehalam>
	<873a29eywq.fsf@basil.nowhere.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger-ZtmgI6mnKB3QT0dZR+AlfA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: andi-Vw/NltI1exuRpAAqCnN02g@public.gmane.org
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <873a29eywq.fsf-3rXA9MLqAseW/qJFnhkgxti2O/JbrIOy@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Andi Kleen <andi-Vw/NltI1exuRpAAqCnN02g@public.gmane.org>
Date: Thu, 14 Jan 2010 11:58:13 +0100

> Stephen Hemminger <shemminger-ZtmgI6mnKB3QT0dZR+AlfA@public.gmane.org> writes:
>>
>> Only TCP is supported, but could also be added to UDP, DCCP, SCTP
>> if desired.
> 
> Perhaps I'm blind, but where is the default set if the socket
> option is not used? 

Socket allocation memset()'s it to zero.
