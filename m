From: Denys Fedoryshchenko <denys@visp.net.lb>
Subject: Re: [PATCH][BUG] tcp: advertise MSS requested by user
Date: Thu, 28 Aug 2008 12:50:34 +0300
Message-ID: <200808281250.35006.denys@visp.net.lb>
References: <48B44768.3030208@gmail.com> <20080828.024617.117112334.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: virtualphtn@gmail.com, netdev@vger.kernel.org,
	lachlan.andrew@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay2.globalproof.net ([194.146.153.25]:50595 "EHLO
	relay2.globalproof.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751866AbYH1JwC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Aug 2008 05:52:02 -0400
In-Reply-To: <20080828.024617.117112334.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> I think this got broken by accident several years ago, shows how many
> people use this feature :)
>
> We used to use ->mss_clamp to determine the MSS option value,
> but along the way when all of the code using ->advmss et al.
> was added it didn't get translated correctly.
>
> Thanks for your patch, I'll mull over this and put in the fix
> once I understand exactly how this got broken.
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
I am using, just i workaround this over iptables MSS option. You feel 
discomfort, but most people start googling and see this trick with iptables, 
and they use it.

