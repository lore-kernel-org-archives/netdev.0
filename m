From: Masahide NAKAMURA <nakam@linux-ipv6.org>
Subject: [RFC] Mobile IPv6 introduction
Date: Sat, 29 Jul 2006 18:23:32 +0900
Message-ID: <44CB2914.9010803@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, anttit@tcs.hut.fi, vnuorval@tcs.hut.fi,
	netdev@vger.kernel.org, usagi-core@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from [203.178.140.9] ([203.178.140.9]:19089 "EHLO mail.gomagoma.org")
	by vger.kernel.org with ESMTP id S1750749AbWG2JXi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 29 Jul 2006 05:23:38 -0400
To: davem@davemloft.net
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

Let me introduce Mobile IPv6(RFC3775) patch and its outline.

We USAGI project and HUT Go/Core project have developed
for Mobile IPv6(MIPv6) stack on 2.6 tree as MIPL2 for several years.
Our aim is to make kernel patch smaller (than MIPL1 which is for
2.4 kernel).

We find out we have 4 categories for the patch:

1. IPv6 policy routing
2. IPsec MIGRATE
3. Advanced XFRM for Correspondent Node(CN)
4. MISC

3, 4 are MIPv6 specific feature but 1, 2 are not.
It can be discussed in parallel about 1, 2, 3 because they
don't depend on others.


1. IPv6 policy routing
Thomas and Yoshifuji have already started to discuss and work for it.
This is required by Mobile Node(MN) and used by Home Agent(HA).

2. IPsec MIGRATE
This is an interface to update IPsec end-point address of SAD/SPD.
(there is an IETF draft: draft-sugimoto-mip6-pfkey-migrate-XX)
This is required by MN and HA to use IPsec tunnel.

3. Advanced XFRM for CN
"Route optimization" defined MIPv6 specification
is designed as XFRM extension. IPv6 extension headers
handling is included, too.
This feature is required by all MIPv6 nodes(CN, MN, HA) then it can
be said MIPv6 platform.

4. MISC
This is a set of small patches but works with the above categories
since they are finally confirmed as the MIPv6 node behavior;
e.g. home addressing for MN, proxy forwarding for HA.


At first I'll send patches about category "3" very soon, just for review.
Can you check them?

Thanks,

-- 
Masahide NAKAMURA






