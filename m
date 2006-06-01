From: Meelis Roos <mroos@linux.ee>
Subject: Re: [Bugme-new] [Bug 6613] New: iptables broken on 32-bit PReP
 (ARCH=ppc)
Date: Thu, 1 Jun 2006 23:50:25 +0300 (EEST)
Message-ID: <Pine.SOC.4.61.0606012346350.28838@math.ut.ee>
References: <200605251004.k4PA4Lek007751@fire-2.osdl.org>
 <20060525070324.2ea16b0a.akpm@osdl.org> <4475FCFC.5000701@trash.net>
 <Pine.SOC.4.61.0606011002180.13777@math.ut.ee> <447F2787.8010203@trash.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: Andrew Morton <akpm@osdl.org>, bugme-daemon@bugzilla.kernel.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from math.ut.ee ([193.40.36.2]:31888 "EHLO math.ut.ee")
	by vger.kernel.org with ESMTP id S1030267AbWFAUue (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Jun 2006 16:50:34 -0400
To: Patrick McHardy <kaber@trash.net>
In-Reply-To: <447F2787.8010203@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> Then lets try something different. Please enable the
> DEBUG_IP_FIREWALL_USER define in net/ipv4/netfilter/ip_tables.c and
> post the results, if any.

On bootup I get this in dmesg (one Bad offset has been added):

ip_tables: (C) 2000-2006 Netfilter Core Team
Netfilter messages via NETLINK v0.30.
ip_conntrack version 2.4 (1536 buckets, 12288 max) - 224 bytes per conntrack
translate_table: size 632
Bad offset cb437924
ip_nat_init: can't setup rules.

And on iptables -t nat -L

translate_table: size 632
Bad offset cb4368f4
ip_nat_init: can't setup rules.
translate_table: size 632
Bad offset cb4368f4
ip_nat_init: can't setup rules.

Seems iptable_nat does not load at all this time.

Modprobe iptable_filter still fails, dmesg contains
translate_table: size 632
Finished chain 1
Finished chain 2
Finished chain 3

Next modprobe iptable_nat gives

translate_table: size 632
Bad offset c8e01944
ip_nat_init: can't setup rules.

-- 
Meelis Roos (mroos@linux.ee)
