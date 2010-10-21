From: Debashis Dutt <ddutt@Brocade.COM>
Subject: Question w.r.t debugfs / netdevice pass-through IOCTL
Date: Wed, 20 Oct 2010 20:26:50 -0700
Message-ID: <F363E7AC84E1B646A0358B281A46F4AEABA0FFCC68@HQ1-EXCH03.corp.brocade.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-000f0801.pphosted.com ([67.231.152.113]:54299 "EHLO
	mx0b-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757205Ab0JUD0z convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Oct 2010 23:26:55 -0400
Received: from pps.filterd (m0000700 [127.0.0.1])
	by mx0b-000f0801.pphosted.com (8.14.4/8.14.4) with SMTP id o9L3GrTq011042
	for <netdev@vger.kernel.org>; Wed, 20 Oct 2010 20:26:53 -0700
Received: from hq1-exedge.brocade.com (hq1-exedge.brocade.com [144.49.141.11])
	by mx0b-000f0801.pphosted.com with ESMTP id s2a5gg3hb-1
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Wed, 20 Oct 2010 20:26:52 -0700
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,=20

=46or the Brocade 10G Ethernet driver (bna) we want to implement a set =
of operations which is not supported by current tools like ethtool.=20

Examples of such operations would be=20
=A0=A0=A0=A0=A0=A0 a) Queries related to CEE, if the link is CEE.
=A0=A0=A0=A0=A0=A0 b) Get traces from firmware.

I was wondering what would be right approach to take here:
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 a) use debugfs (like the =
Chelsio cxgb4 driver)
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 b) use SIOCDEVPRIVATE for=
 the pass through IOCTL defined in
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

