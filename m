From: Tom Herbert <tom@herbertland.com>
Subject: Re: [PATCH v8 04/11] net/mlx4_en: add support for fast rx drop bpf program
Date: Fri, 15 Jul 2016 11:08:06 -0700
Message-ID: <CALx6S36xCmzOEtyVm54Z4kJm+rFf+NppWa5WbPcdyEJuQ_Op5A@mail.gmail.com>
References: <1468309894-26258-1-git-send-email-bblanco@plumgrid.com>
 <1468309894-26258-5-git-send-email-bblanco@plumgrid.com> <20160714092543.776f8d8c@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Brenden Blanco <bblanco@plumgrid.com>,
	"David S. Miller" <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Saeed Mahameed <saeedm@dev.mellanox.co.il>,
	Martin KaFai Lau <kafai@fb.com>, Ari Saha <as754m@att.com>,
	Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	Or Gerlitz <gerlitz.or@gmail.com>,
	john fastabend <john.fastabend@gmail.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Thomas Graf <tgraf@suug.ch>,
	Daniel Borkmann <daniel@iogearbox.net>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f50.google.com ([209.85.214.50]:38727 "EHLO
	mail-it0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751081AbcGOSIH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Jul 2016 14:08:07 -0400
Received: by mail-it0-f50.google.com with SMTP id h190so25875725ith.1
        for <netdev@vger.kernel.org>; Fri, 15 Jul 2016 11:08:07 -0700 (PDT)
In-Reply-To: <20160714092543.776f8d8c@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jul 14, 2016 at 12:25 AM, Jesper Dangaard Brouer
<brouer@redhat.com> wrote:
>
> I would really really like to see the XDP program associated with the
> RX ring queues, instead of a single XDP program covering the entire NIC.
> (Just move the bpf_prog pointer to struct mlx4_en_rx_ring)
>
I think it would be helpful to have some concrete implementation to
look at for this. Jesper, can you code up some patches, taking into
account Alexei's concerns about the atomic program update problem?.

Thanks,
Tom
