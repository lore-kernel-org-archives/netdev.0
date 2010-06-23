From: Patrick McHardy <kaber@trash.net>
Subject: Re: Question about xfrm by MARK feature
Date: Wed, 23 Jun 2010 18:15:12 +0200
Message-ID: <4C223310.6090006@trash.net>
References: <201006231803.17261.lists@egidy.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: jamal <hadi@cyberus.ca>, timo.teras@iki.fi,
	herbert@gondor.apana.org.au, netdev@vger.kernel.org
To: "Gerd v. Egidy" <lists@egidy.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:44238 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751526Ab0FWQPQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Jun 2010 12:15:16 -0400
In-Reply-To: <201006231803.17261.lists@egidy.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Gerd v. Egidy wrote:
> Hi Jamal,
>
> while looking through the 2.6.34 changelog I found the xfrm by MARK feature 
> you developed in february. I'm currently working on NAT for ipsec connections 
> and thought your feature might help me.
>
> For example I have 2 different remote networks with the same ip network each 
> and both of them have a tunnel to the same local network. I map their IPs to 
> something different so I can distinguish them in the local network. But after 
> the nat the xfrm code sees two tunnels with exactly the same values. So this 
> can't work.
>
> But if I understood your feature correctly, I can now mark the packets (e.g. 
> in iptables with ... -j MARK --set-mark 1) and have xfrm select the correct 
> ipsec tunnel via the mark. Correct?
>
> But does your feature also set the mark on packets decrypted by xfrm? I need 
> some way to find out from which tunnel the packet came to correctly treat it. 
>   

You should be able to use the policy match to distinguish the tunnels,
f.i. by matching on the tunnel endpoints.

