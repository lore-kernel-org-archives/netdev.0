From: Debashis Dutt <ddutt@Brocade.COM>
Subject: (unknown)
Date: Wed, 20 Oct 2010 20:07:45 -0700
Message-ID: <F363E7AC84E1B646A0358B281A46F4AEABA0FFCC62@HQ1-EXCH03.corp.brocade.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Rasesh Mody <rmody@brocade.com>, Jing Huang <huangj@Brocade.COM>,
	"Akshay Mathur" <amathur@brocade.com>
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-000f0801.pphosted.com ([67.231.144.122]:39990 "EHLO
	mx0a-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756915Ab0JUDHu convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Oct 2010 23:07:50 -0400
Subject: 
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,=20

=46or the Brocade 10G Ethernet driver (bna) we want to implement a set =
of=20
operations which is not supported by current tools like ethtool.=20

Examples of such operations would be=20
       a) Queries related to CEE, if the link is CEE.
       b) Get traces from firmware.

I was wondering what would be right approach to take here:
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 a) use debugfs (like the =
Chelsio cxgb4 driver)
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 b) use SIOCDEVPRIVATE for=
 the pass through IOCTL defined in=20
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 =A0=A0=A0 struct net_devi=
ce_ops{}
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 =A0=A0=A0 As per comments=
 in the header file, b) should not be used
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 =A0=A0=A0 since this IOCT=
L is supposed to be deprecated.
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 c) use procfs / sysfs (th=
ese may not scale, in our opinion)

Please suggest.

Thanks
--Debashis

