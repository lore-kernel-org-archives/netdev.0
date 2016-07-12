From: Tariq Toukan <tariqt@mellanox.com>
Subject: RE: [PATCH v8 04/11] net/mlx4_en: add support for fast rx drop bpf
 program
Date: Tue, 12 Jul 2016 12:02:28 +0000
Message-ID: <AM4PR05MB15536151D58A53E728E3DEDFAE300@AM4PR05MB1553.eurprd05.prod.outlook.com>
References: <1468309894-26258-1-git-send-email-bblanco@plumgrid.com>
 <1468309894-26258-5-git-send-email-bblanco@plumgrid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Jamal Hadi Salim <jhs@mojatatu.com>,
	Saeed Mahameed <saeedm@dev.mellanox.co.il>,
	Martin KaFai Lau <kafai@fb.com>,
	"Jesper Dangaard Brouer" <brouer@redhat.com>,
	Ari Saha <as754m@att.com>,
	"Alexei Starovoitov" <alexei.starovoitov@gmail.com>,
	Or Gerlitz <gerlitz.or@gmail.com>,
	"john.fastabend@gmail.com" <john.fastabend@gmail.com>,
	"hannes@stressinduktion.org" <hannes@stressinduktion.org>,
	Thomas Graf <tgraf@suug.ch>, Tom Herbert <tom@herbertland.com>,
	Daniel Borkmann <daniel@iogearbox.net>
To: Brenden Blanco <bblanco@plumgrid.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-eopbgr20045.outbound.protection.outlook.com ([40.107.2.45]:64757
	"EHLO EUR02-VE1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750717AbcGLNgt convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Jul 2016 09:36:49 -0400
In-Reply-To: <1468309894-26258-5-git-send-email-bblanco@plumgrid.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


>Add support for the BPF_PROG_TYPE_XDP hook in mlx4 driver.
>
>In tc/socket bpf programs, helpers linearize skb fragments as needed when the program touches the packet data. However, in the pursuit of speed, XDP programs will not be allowed to use these slower functions, especially if it involves allocating an skb.
>
>Therefore, disallow MTU settings that would produce a multi-fragment packet that XDP programs would fail to access. Future enhancements could be done to increase the allowable MTU.
>
>Signed-off-by: Brenden Blanco <bblanco@plumgrid.com>

Reviewed-by: Tariq Toukan <tariqt@mellanox.com>
