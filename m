From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: curent state of GSO over IPv6 tunnel
Date: Mon, 15 Sep 2014 08:55:23 +0000
Message-ID: <B5657A6538887040AD3A81F1008BEC63B365F6@avmb3.qlogic.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:1392 "EHLO
	mx0a-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752712AbaIOIzZ convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 15 Sep 2014 04:55:25 -0400
Received: from pps.filterd (m0045602.ppops.net [127.0.0.1])
	by mx0a-0016ce01.pphosted.com (8.14.5/8.14.5) with SMTP id s8F8tPf5009870
	for <netdev@vger.kernel.org>; Mon, 15 Sep 2014 01:55:25 -0700
Received: from avcashub1.qlogic.com (avcashub1.qlogic.com [198.70.193.115])
	by mx0a-0016ce01.pphosted.com with ESMTP id 1patsxg0js-1
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Mon, 15 Sep 2014 01:55:25 -0700
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Tried running simple scenarios using ipv6/ipv6 via gre-tunnel [ip6_gre].

When I've tried sniffing Tx traffic [tcpdump] I've noticed there were
no aggregations being set, i.e., only MTU-sized packets reached NIC.

Looking at output of `ethtool -k', I can see `tx_gre_segmentation' is on.

What's the current state of the feature? Is it feasible and I'm missing
some configuration, or is it yet an unsupported feature?

Thanks,
Yuval

________________________________

This message and any attached documents contain information from QLogic Corporation or its wholly-owned subsidiaries that may be confidential. If you are not the intended recipient, you may not read, copy, distribute, or use this information. If you have received this transmission in error, please notify the sender immediately by reply e-mail and then delete this message.
