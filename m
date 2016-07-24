From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [PATCH v10 05/12] net/mlx4_en: add support for fast rx drop bpf
 program
Date: Sun, 24 Jul 2016 13:56:00 +0200
Message-ID: <20160724135600.636742ed@redhat.com>
References: <1468955817-10604-1-git-send-email-bblanco@plumgrid.com>
	<1468955817-10604-6-git-send-email-bblanco@plumgrid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Saeed Mahameed <saeedm@dev.mellanox.co.il>,
	Martin KaFai Lau <kafai@fb.com>, Ari Saha <as754m@att.com>,
	Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	Or Gerlitz <gerlitz.or@gmail.com>, john.fastabend@gmail.com,
	hannes@stressinduktion.org, Thomas Graf <tgraf@suug.ch>,
	Tom Herbert <tom@herbertland.com>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Tariq Toukan <ttoukan.linux@gmail.com>, brouer@redhat.com
To: Brenden Blanco <bblanco@plumgrid.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:56383 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752094AbcGXL4L (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 24 Jul 2016 07:56:11 -0400
In-Reply-To: <1468955817-10604-6-git-send-email-bblanco@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 19 Jul 2016 12:16:50 -0700
Brenden Blanco <bblanco@plumgrid.com> wrote:

> The xdp program is present as a per-ring data structure, but as of yet
> it is not possible to set at that granularity through any ndo.

Thank you for doing this! :-)

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer
