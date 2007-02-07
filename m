From: Ingo Oeser <netdev@axxeo.de>
Subject: Re: Funny Routing change since 2.6.16.x
Date: Wed, 7 Feb 2007 18:16:27 +0100
Message-ID: <200702071816.28235.netdev@axxeo.de>
References: <200702071756.34409.netdev@axxeo.de> <45CA0737.40308@trash.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.axxeo.de ([82.100.226.146]:1470 "EHLO mail.axxeo.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1161386AbXBGRQk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 7 Feb 2007 12:16:40 -0500
In-Reply-To: <45CA0737.40308@trash.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Patrick McHardy schrieb:
> My guess is that you're using MASQUERADE on ppp0, which since 2.6.14
> doesn't exclude locally generated packets anymore, so it translates
> them to the primary ppp0 address. For replies it works because NAT
> is already set up for the incoming packet, without masquerading.

Your guess is right! Thanks for that hint. Do you have any idea, how to
restore the old behavior? 

I have to, because the ISP cannot assign a different local address
and have problems with the new behavior, because that IP adress is an MX entry
and the VPN gateway address for several third party vendor tunnels. 
So changing that is quite an effort.

Many thanks for your quick answer.

Best regards

Ingo Oeser
