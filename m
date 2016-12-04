From: Martin KaFai Lau <kafai@fb.com>
Subject: [PATCH v2 net-next 0/4]: Allow head adjustment in XDP prog
Date: Sat, 3 Dec 2016 19:17:22 -0800
Message-ID: <1480821446-4122277-1-git-send-email-kafai@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Alexei Starovoitov <ast@fb.com>,
        Brenden Blanco <bblanco@plumgrid.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        David Miller <davem@davemloft.net>,
        Jesper Dangaard Brouer <brouer@redhat.com>,
        Saeed Mahameed <saeedm@mellanox.com>,
        Tariq Toukan <tariqt@mellanox.com>,
        Kernel Team <kernel-team@fb.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:57676 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751939AbcLDDRc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 3 Dec 2016 22:17:32 -0500
Received: from pps.filterd (m0044012.ppops.net [127.0.0.1])
        by mx0a-00082601.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id uB43F1p2032535
        for <netdev@vger.kernel.org>; Sat, 3 Dec 2016 19:17:32 -0800
Received: from mail.thefacebook.com ([199.201.64.23])
        by mx0a-00082601.pphosted.com with ESMTP id 273vmdj8a2-1
        (version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Sat, 03 Dec 2016 19:17:32 -0800
Received: from facebook.com (2401:db00:11:d0a6:face:0:33:0)     by
 mx-out.facebook.com (10.103.99.97) with ESMTP  id
 312b5e82b9d011e69efb0002c9931860-edffca50 for <netdev@vger.kernel.org>;        Sat,
 03 Dec 2016 19:17:31 -0800
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series adds a helper to allow head adjusting in XDP prog.  mlx4
driver has been modified to support this feature.  An example is written
to encapsulate a packet with an IPv4/v6 header and then XDP_TX it
out.

v2:
1. Make a variable name change in bpf_xdp_adjust_head() in patch 1
2. Ensure no less than ETH_HLEN data in bpf_xdp_adjust_head() in patch 1
3. Some clarifications in commit log messages of patch 2 and 3

Thanks,
--Martin
