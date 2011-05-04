From: Krishna Kumar <krkumar2@in.ibm.com>
Subject: Re: [PATCH 0/4] [RFC] virtio-net: Improve small packet performance
Date: Wed, 04 May 2011 19:40:22 +0530
Message-ID: <20110504141022.14989.98562.sendpatchset@krkumar2.in.ibm.com>
Cc: eric.dumazet@gmail.com, kvm@vger.kernel.org, mst@redhat.com,
	netdev@vger.kernel.org, rusty@rustcorp.com.au,
	Krishna Kumar <krkumar2@in.ibm.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e28smtp05.in.ibm.com ([122.248.162.5]:60149 "EHLO
	e28smtp05.in.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753478Ab1EDOK0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 May 2011 10:10:26 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Krishna Kumar2/India/IBM@IBMIN wrote on 05/04/2011 07:32:58 PM:

> [PATCH 0/4] [RFC] virtio-net: Improve small packet performance

I found having tabs in the table made the results a little
difficult to understand. Converting the same to spaces, hope
it is clear this time.

________________________________________________________
               I/O Size: 1K
#     BW1      BW2 (%)            SD1       SD2 (%)
________________________________________________________
1     1226     3313 (170.2)       6.6       1.9 (-71.2)
2     3223     7705 (139.0)       18.0      7.1 (-60.5)
4     7223     8716 (20.6)        36.5      29.7 (-18.6)
8     8689     8693 (0)           131.5     123.0 (-6.4)
16    8059     8285 (2.8)         578.3     506.2 (-12.4)
32    7758     7955 (2.5)         2281.4    2244.2 (-1.6)
64    7503     7895 (5.2)         9734.0    9424.4 (-3.1)
96    7496     7751 (3.4)         21980.9   20169.3 (-8.2)
128   7389     7741 (4.7)         40467.5   34995.5 (-13.5)
________________________________________________________
Summary:     BW: 16.2%     SD: -10.2%

________________________________________________________
               I/O Size: 16K
#     BW1      BW2 (%)            SD1       SD2 (%)
________________________________________________________
1     6684     7019 (5.0)         1.1       1.1 (0)
2     7674     7196 (-6.2)        5.0       4.8 (-4.0)
4     7358     8032 (9.1)         21.3      20.4 (-4.2)
8     7393     8015 (8.4)         82.7      82.0 (-.8)
16    7958     8366 (5.1)         283.2     310.7 (9.7)
32    7792     8113 (4.1)         1257.5    1363.0 (8.3)
64    7673     8040 (4.7)         5723.1    5812.4 (1.5)
96    7462     7883 (5.6)         12731.8   12119.8 (-4.8)
128   7338     7800 (6.2)         21331.7   21094.7 (-1.1)
________________________________________________________
Summary:     BW: 4.6%     SD: -1.5%
