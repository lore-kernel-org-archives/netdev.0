From: "Gerd v. Egidy" <lists@egidy.de>
Subject: Question about xfrm by MARK feature
Date: Wed, 23 Jun 2010 18:03:16 +0200
Message-ID: <201006231803.17261.lists@egidy.de>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: timo.teras@iki.fi, kaber@trash.net, herbert@gondor.apana.org.au,
	netdev@vger.kernel.org
To: jamal <hadi@cyberus.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rs02.intra2net.com ([81.169.173.116]:52888 "EHLO
	rs02.intra2net.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753230Ab0FWQJI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Jun 2010 12:09:08 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Jamal,

while looking through the 2.6.34 changelog I found the xfrm by MARK feature 
you developed in february. I'm currently working on NAT for ipsec connections 
and thought your feature might help me.

For example I have 2 different remote networks with the same ip network each 
and both of them have a tunnel to the same local network. I map their IPs to 
something different so I can distinguish them in the local network. But after 
the nat the xfrm code sees two tunnels with exactly the same values. So this 
can't work.

But if I understood your feature correctly, I can now mark the packets (e.g. 
in iptables with ... -j MARK --set-mark 1) and have xfrm select the correct 
ipsec tunnel via the mark. Correct?

But does your feature also set the mark on packets decrypted by xfrm? I need 
some way to find out from which tunnel the packet came to correctly treat it. 

Do you know if any of the ipsec solutions for linux (e.g. strongswan, 
openswan, racoon) already have support for this feature or are developing on 
it?

Kind regards,

Gerd

-- 
Address (better: trap) for people I really don't want to get mail from:
jonas@cactusamerica.com
