From: Patrick McHardy <kaber@trash.net>
Subject: Re: [Bugme-new] [Bug 6613] New: iptables broken on 32-bit PReP (ARCH=ppc)
Date: Fri, 02 Jun 2006 15:56:09 +0200
Message-ID: <44804379.60808@trash.net>
References: <200605251004.k4PA4Lek007751@fire-2.osdl.org> <20060525070324.2ea16b0a.akpm@osdl.org> <4475FCFC.5000701@trash.net> <Pine.SOC.4.61.0606011002180.13777@math.ut.ee> <447F2787.8010203@trash.net> <Pine.SOC.4.61.0606012346350.28838@math.ut.ee> <4480385C.7080405@trash.net> <Pine.SOC.4.61.0606021617480.1298@math.ut.ee>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@osdl.org>, bugme-daemon@bugzilla.kernel.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:53491 "EHLO
	stinky.trash.net") by vger.kernel.org with ESMTP id S932113AbWFBN4K
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 2 Jun 2006 09:56:10 -0400
To: Meelis Roos <mroos@linux.ee>
In-Reply-To: <Pine.SOC.4.61.0606021617480.1298@math.ut.ee>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Meelis Roos wrote:
>> Very strange, this means that the initial table data must somehow
>> be wrong, but for some reason it still seems to get past the
>> size and offset checks for the filter table. I can't see how
>> loading the filter table could fail after the "Finished chain .."
>> messages without another message. Which kernel version did you
>> perform these test on?
> 
> 
> Yesterdays 2.6.17-rc5+git.

Please enable DEBUG_IP_FIREWALL_USER in net/netfilter/x_tables.c as well
and retry. Results of the raw or mangle table would also be interesting
because they contain a different number of built-in chains.
