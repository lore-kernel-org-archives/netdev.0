From: Tan Xiaojun <tanxiaojun@huawei.com>
Subject: =?UTF-8?Q?IP_ID_check_=28flush=5fid=29_in_inet=5fgro=5freceive_is_n?=
 =?UTF-8?Q?ecessary_or_not=ef=bc=9f?=
Date: Tue, 28 Jun 2016 12:40:01 +0800
Message-ID: <5771FFA1.3050306@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>
To: <davem@davemloft.net>, <kuznet@ms2.inr.ac.ru>, <jmorris@namei.org>,
	<yoshfuji@linux-ipv6.org>, <kaber@trash.net>,
	<aduyck@mirantis.com>, <hkchu@google.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi everyone,

	I'm sorry to bother you. But I was confused.

	The IP ID check (flush_id) in inet_gro_receive is only used by tcp_gro_receive, and in tcp_gro_receive we have tcphdr check to ensure the order of skbs,
	like below:

	flush |= (__force int)(th->ack_seq ^ th2->ack_seq);
	flush |= (ntohl(th2->seq) + skb_gro_len(p)) ^ ntohl(th->seq);

	So if I remove the IP ID check in inet_gro_receive, there will be a problem ? And under what circumstances ?


Thanks.
Xiaojun.
