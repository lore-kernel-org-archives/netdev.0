From: Patrick McHardy <kaber@trash.net>
Subject: Re: [Bugme-new] [Bug 6613] New: iptables broken on 32-bit PReP (ARCH=ppc)
Date: Thu, 01 Jun 2006 19:44:39 +0200
Message-ID: <447F2787.8010203@trash.net>
References: <200605251004.k4PA4Lek007751@fire-2.osdl.org> <20060525070324.2ea16b0a.akpm@osdl.org> <4475FCFC.5000701@trash.net> <Pine.SOC.4.61.0606011002180.13777@math.ut.ee>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@osdl.org>, bugme-daemon@bugzilla.kernel.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:23168 "EHLO
	stinky.trash.net") by vger.kernel.org with ESMTP id S965248AbWFARok
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 1 Jun 2006 13:44:40 -0400
To: Meelis Roos <mroos@linux.ee>
In-Reply-To: <Pine.SOC.4.61.0606011002180.13777@math.ut.ee>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Meelis Roos wrote:
>> Meelis, it would really help if you could try 2.6.16 and in case
>> that doesn't work 2.6.15 to give an idea about whether this is a
>> recent regression or an old problem. We had a number of changes
>> in this area in the last two kernel versions that could be related.
> 
> 
> Have not gotten 2.6.15 to work with one evening of tinkering - the irq
> patch was not sufficent, there is something more broken in booting that
> I dodn't figure out yet. So no test results for 2.6.15 yet.

Then lets try something different. Please enable the
DEBUG_IP_FIREWALL_USER define in net/ipv4/netfilter/ip_tables.c and
post the results, if any.
