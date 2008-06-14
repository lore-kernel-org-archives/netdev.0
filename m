From: "Chas Williams (CONTRACTOR)" <chas@cmf.nrl.navy.mil>
Subject: Re: [PATCH][ATM] br2684: Fix oops due to skb->dev being NULL
Date: Sat, 14 Jun 2008 17:21:51 -0400
Message-ID: <200806142121.m5ELLpDt004125@cmf.nrl.navy.mil>
References: <484809B6.2080904@dti2.net>
Reply-To: chas3@users.sourceforge.net
Cc: netdev@vger.kernel.org
To: jorge@dti2.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from hedwig.cmf.nrl.navy.mil ([134.207.12.162]:45595 "EHLO
	hedwig.cmf.nrl.navy.mil" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755562AbYFNVWG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 Jun 2008 17:22:06 -0400
In-reply-to: <484809B6.2080904@dti2.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In message <484809B6.2080904@dti2.net>,"Jorge Boncompte [DTI2]" writes:
>	It happens that if a packet arrives in a VC between the call to open it
> 
>on the hardware and the call to change the backend to br2684, 
>br2684_regvcc processes the packet and oopses dereferencing skb->dev 
>because it is NULL before the call to br2684_push().
>
>Signed-off-by: Jorge Boncompte [DTI2] <jorge@dti2.net>

looks good. i will submit to davem with the next batch of atm patches.
