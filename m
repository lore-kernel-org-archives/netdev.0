From: Alexei Starovoitov <ast@fb.com>
Subject: Re: [PATCH net-next] samples: Add an IPv6 '-6' option to the pktgen
 scripts
Date: Wed, 20 Jul 2016 15:53:39 -0700
Message-ID: <579000F3.2080401@fb.com>
References: <1469054923-4178431-1-git-send-email-kafai@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <kernel-team@fb.com>
To: Martin KaFai Lau <kafai@fb.com>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:52910 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755127AbcGTWxy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Jul 2016 18:53:54 -0400
Received: from pps.filterd (m0044010.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.11/8.16.0.11) with SMTP id u6KMfxK8001673
	for <netdev@vger.kernel.org>; Wed, 20 Jul 2016 15:53:54 -0700
Received: from maileast.thefacebook.com ([199.201.65.23])
	by mx0a-00082601.pphosted.com with ESMTP id 24ahysg537-1
	(version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
	for <netdev@vger.kernel.org>; Wed, 20 Jul 2016 15:53:54 -0700
In-Reply-To: <1469054923-4178431-1-git-send-email-kafai@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 7/20/16 3:48 PM, Martin KaFai Lau wrote:
> Add a '-6' option to the sample pktgen scripts for sending out
> IPv6 packets.
>
> [root@kerneldev010.prn1 ~/pktgen]# ./pktgen_sample03_burst_single_flow.sh -i eth0 -s 64 -d fe80::f652:14ff:fec2:a14c -m f4:52:14:c2:a1:4c -b 32 -6
>
> [root@kerneldev011.prn1 ~]# tcpdump -i eth0 -nn -c3 port 9
> tcpdump: WARNING: eth0: no IPv4 address assigned
> tcpdump: verbose output suppressed, use -v or -vv for full protocol decode
> listening on eth0, link-type EN10MB (Ethernet), capture size 65535 bytes
> 14:38:51.815297 IP6 fe80::f652:14ff:fec2:2ad2.9 > fe80::f652:14ff:fec2:a14c.9: UDP, length 16
> 14:38:51.815311 IP6 fe80::f652:14ff:fec2:2ad2.9 > fe80::f652:14ff:fec2:a14c.9: UDP, length 16
> 14:38:51.815313 IP6 fe80::f652:14ff:fec2:2ad2.9 > fe80::f652:14ff:fec2:a14c.9: UDP, length 16
>
> Signed-off-by: Martin KaFai Lau <kafai@fb.com>

Awesome. Thanks!
Acked-by: Alexei Starovoitov <ast@kernel.org>

kerneldev011.prn1 lol :)
