From: "Alex G." <mr.nuke.me@gmail.com>
Subject: Re: [PATCH] via-rhine: do not abort due to invalid MAC address
Date: Wed, 02 Mar 2011 20:11:08 +0200
Message-ID: <4D6E883C.2000800@gmail.com>
References: <20110302163233.GA14491@core.hellgate.ch> <201103021901.39849.florian@openwrt.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Roger Luethi <rl@hellgate.ch>, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>
To: Florian Fainelli <florian@openwrt.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:39950 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756439Ab1CBSPl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Mar 2011 13:15:41 -0500
Received: by bwz15 with SMTP id 15so412341bwz.19
        for <netdev@vger.kernel.org>; Wed, 02 Mar 2011 10:15:40 -0800 (PST)
In-Reply-To: <201103021901.39849.florian@openwrt.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/02/2011 08:01 PM, Florian Fainelli wrote:
> 
> Why not generate a valid random ethernet address using random_ether_addr() 
> instead?

That would confuse ifcfg-* scripts that specify HWETHER, and probably
users as well. It might even stump udev.

An "ifconfig ethX hw ether xx:xx:xx:xx:xx:xx" in network scripts allows
udev to use the consistent "bad" MAC to assign a consistent ethX number,
and allows the networking scripts to use the consistent "new good" MAC.
It works as a stand-alone interface, as a WAN port hosting ppp0, and
even in bonding, all consistently.

Alex
