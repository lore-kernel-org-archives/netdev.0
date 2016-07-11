From: Brenden Blanco <bblanco@plumgrid.com>
Subject: Re: [PATCH v7 00/11] Add driver bpf hook for early packet drop and
 forwarding
Date: Mon, 11 Jul 2016 15:06:33 -0700
Message-ID: <20160711220632.GD22729@gmail.com>
References: <1468272598-21390-1-git-send-email-bblanco@plumgrid.com>
 <CAJ3xEMgVtqETM8XHt5gedAmKoBGwggnKDr3iWUeRYFtvQRfQEw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Saeed Mahameed <saeedm@dev.mellanox.co.il>,
	Martin KaFai Lau <kafai@fb.com>,
	Jesper Dangaard Brouer <brouer@redhat.com>,
	Ari Saha <as754m@att.com>,
	Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	john fastabend <john.fastabend@gmail.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Thomas Graf <tgraf@suug.ch>, Tom Herbert <tom@herbertland.com>,
	Daniel Borkmann <daniel@iogearbox.net>
To: Or Gerlitz <gerlitz.or@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:35948 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751186AbcGKWGh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Jul 2016 18:06:37 -0400
Received: by mail-pa0-f48.google.com with SMTP id hu1so26197003pad.3
        for <netdev@vger.kernel.org>; Mon, 11 Jul 2016 15:06:37 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <CAJ3xEMgVtqETM8XHt5gedAmKoBGwggnKDr3iWUeRYFtvQRfQEw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 12, 2016 at 12:53:34AM +0300, Or Gerlitz wrote:
> On Tue, Jul 12, 2016 at 12:29 AM, Brenden Blanco <bblanco@plumgrid.com> wrote:
> 
> > v7:
> [...]
> >  TODOs:
> >  Add ethtool per-ring stats for aborted, default cases, maybe even drop
> >  and tx as well.
> 
> please no... lets stop and think if we can have something better vs
> every XDP enabled driver to have bunch of new ethtool based stats, was
> this somehow discussed over the threads so far?
This was in the context of the discussion in [01/12] relating to the
return codes and debuggability.
