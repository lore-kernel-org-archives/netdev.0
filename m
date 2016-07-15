From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [PATCH v8 04/11] net/mlx4_en: add support for fast rx drop bpf
 program
Date: Fri, 15 Jul 2016 20:45:10 +0200
Message-ID: <20160715204510.19a12bd3@redhat.com>
References: <1468309894-26258-1-git-send-email-bblanco@plumgrid.com>
	<1468309894-26258-5-git-send-email-bblanco@plumgrid.com>
	<20160714092543.776f8d8c@redhat.com>
	<CALx6S36xCmzOEtyVm54Z4kJm+rFf+NppWa5WbPcdyEJuQ_Op5A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
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
	Daniel Borkmann <daniel@iogearbox.net>, brouer@redhat.com
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:58340 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751340AbcGOSpS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 15 Jul 2016 14:45:18 -0400
In-Reply-To: <CALx6S36xCmzOEtyVm54Z4kJm+rFf+NppWa5WbPcdyEJuQ_Op5A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 15 Jul 2016 11:08:06 -0700
Tom Herbert <tom@herbertland.com> wrote:

> On Thu, Jul 14, 2016 at 12:25 AM, Jesper Dangaard Brouer
> <brouer@redhat.com> wrote:
> >
> > I would really really like to see the XDP program associated with the
> > RX ring queues, instead of a single XDP program covering the entire NIC.
> > (Just move the bpf_prog pointer to struct mlx4_en_rx_ring)
> >  
> I think it would be helpful to have some concrete implementation to
> look at for this. Jesper, can you code up some patches, taking into
> account Alexei's concerns about the atomic program update problem?.

Bad timing, as I'm going on 3 weeks vacation from today.

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer
