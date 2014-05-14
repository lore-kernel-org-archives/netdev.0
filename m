From: David Newall <davidn@davidnewall.com>
Subject: Re: Bad checksum on bridge with IP options
Date: Wed, 14 May 2014 22:38:28 +0930
Message-ID: <53736ACC.9010902@davidnewall.com>
References: <536F8C0F.4090206@davidnewall.com>,<5370CB47.4010400@davidnewall.com> <DUB123-W514EA0A4A29F520778F2FFED350@phx.gbl> <53715D67.8020803@davidnewall.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "fw@strlen.de" <fw@strlen.de>
To: Lukas Tribus <luky-37@hotmail.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hawking.rebel.net.au ([203.20.69.83]:60248 "EHLO
	hawking.rebel.net.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932072AbaENNIc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 May 2014 09:08:32 -0400
In-Reply-To: <53715D67.8020803@davidnewall.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

My thought of calling ip_forward_options to set RR and TS addresses (not 
to mention checksum) is not working out, because skb_rtable returns 
NULL.  I think I'm supposed to call skb_set_dst, but how
I get dst is eluding me.

Leaving broken values in the options, just recalculating the checksum, 
is starting to look very attractive right now, but I'd rather not.

How do I proceed?
