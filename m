From: "Gerd v. Egidy" <lists@egidy.de>
Subject: Re: Question about xfrm by MARK feature
Date: Thu, 24 Jun 2010 00:13:57 +0200
Message-ID: <201006240013.58261.lists@egidy.de>
References: <201006231803.17261.lists@egidy.de> <4C223310.6090006@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: jamal <hadi@cyberus.ca>, timo.teras@iki.fi,
	herbert@gondor.apana.org.au, netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rs02.intra2net.com ([81.169.173.116]:42139 "EHLO
	rs02.intra2net.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753509Ab0FWWOC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Jun 2010 18:14:02 -0400
In-Reply-To: <4C223310.6090006@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> > But does your feature also set the mark on packets decrypted by xfrm? I
> > need some way to find out from which tunnel the packet came to correctly
> > treat it.
> 
> You should be able to use the policy match to distinguish the tunnels,
> f.i. by matching on the tunnel endpoints.

That would work for endpoints with fixed ips. But as soon as the endpoint has a 
dynamic ip, I'd have to change the iptables depending on the vpns currently 
connected. This is something I want to avoid in any case. 

Reason is that I'd have to introduce some kind of locking around the calls to 
iptables. Otherwise two connections established or disconnected nearly 
simultaneously could result in loss of the rules for one of them.

Kind regards,

Gerd
