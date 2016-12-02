From: Martin KaFai Lau <kafai@fb.com>
Subject: [PATCH net-next 0/4]: Allow head adjustment in XDP prog
Date: Fri, 2 Dec 2016 15:23:29 -0800
Message-ID: <1480721013-1047541-1-git-send-email-kafai@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Alexei Starovoitov <ast@fb.com>,
        Brenden Blanco <bblanco@plumgrid.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        David Miller <davem@davemloft.net>,
        Saeed Mahameed <saeedm@mellanox.com>,
        Tariq Toukan <tariqt@mellanox.com>,
        Kernel Team <kernel-team@fb.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:35825 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1753824AbcLBXgx (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 2 Dec 2016 18:36:53 -0500
Received: from pps.filterd (m0001303.ppops.net [127.0.0.1])
        by m0001303.ppops.net (8.16.0.17/8.16.0.17) with SMTP id uB2NHIeY007504
        for <netdev@vger.kernel.org>; Fri, 2 Dec 2016 15:24:02 -0800
Received: from mail.thefacebook.com ([199.201.64.23])
        by m0001303.ppops.net with ESMTP id 273f1t9nag-3
        (version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Fri, 02 Dec 2016 15:24:02 -0800
Received: from facebook.com (2401:db00:11:d0a6:face:0:33:0)     by
 mx-out.facebook.com (10.222.219.45) with ESMTP id
 6793b9d2b8e611e6983c24be05904660-853da6d0 for <netdev@vger.kernel.org>;        Fri,
 02 Dec 2016 15:24:00 -0800
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series adds a helper to allow head adjustment in XDP prog.  mlx4
driver has been modified to support this feature.  An example is written
to encapsulate a packet with an IPv4/v6 header and then XDP_TX it
out.

Thanks,
--Martin
