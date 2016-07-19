From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH v10 02/12] bpf: add XDP prog type for early driver filter
Date: Tue, 19 Jul 2016 14:33:15 -0700
Message-ID: <20160719213314.GA64618@ast-mbp.thefacebook.com>
References: <1468955817-10604-1-git-send-email-bblanco@plumgrid.com>
 <1468955817-10604-3-git-send-email-bblanco@plumgrid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Saeed Mahameed <saeedm@dev.mellanox.co.il>,
	Martin KaFai Lau <kafai@fb.com>,
	Jesper Dangaard Brouer <brouer@redhat.com>,
	Ari Saha <as754m@att.com>, Or Gerlitz <gerlitz.or@gmail.com>,
	john.fastabend@gmail.com, hannes@stressinduktion.org,
	Thomas Graf <tgraf@suug.ch>, Tom Herbert <tom@herbertland.com>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Tariq Toukan <ttoukan.linux@gmail.com>
To: Brenden Blanco <bblanco@plumgrid.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f182.google.com ([209.85.192.182]:36363 "EHLO
	mail-pf0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751849AbcGSVdV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Jul 2016 17:33:21 -0400
Received: by mail-pf0-f182.google.com with SMTP id h186so11122511pfg.3
        for <netdev@vger.kernel.org>; Tue, 19 Jul 2016 14:33:21 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1468955817-10604-3-git-send-email-bblanco@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 19, 2016 at 12:16:47PM -0700, Brenden Blanco wrote:
> Add a new bpf prog type that is intended to run in early stages of the
> packet rx path. Only minimal packet metadata will be available, hence a
> new context type, struct xdp_md, is exposed to userspace. So far only
> expose the packet start and end pointers, and only in read mode.
> 
> An XDP program must return one of the well known enum values, all other
> return codes are reserved for future use. Unfortunately, this
> restriction is hard to enforce at verification time, so take the
> approach of warning at runtime when such programs are encountered. Out
> of bounds return codes should alias to XDP_ABORTED.
> 
> Signed-off-by: Brenden Blanco <bblanco@plumgrid.com>

Acked-by: Alexei Starovoitov <ast@kernel.org>
