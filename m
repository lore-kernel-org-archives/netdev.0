From: Or Gerlitz <gerlitz.or@gmail.com>
Subject: Re: [PATCH v7 00/11] Add driver bpf hook for early packet drop and forwarding
Date: Tue, 12 Jul 2016 00:53:34 +0300
Message-ID: <CAJ3xEMgVtqETM8XHt5gedAmKoBGwggnKDr3iWUeRYFtvQRfQEw@mail.gmail.com>
References: <1468272598-21390-1-git-send-email-bblanco@plumgrid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
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
To: Brenden Blanco <bblanco@plumgrid.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f43.google.com ([209.85.218.43]:32905 "EHLO
	mail-oi0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751042AbcGKVxf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Jul 2016 17:53:35 -0400
Received: by mail-oi0-f43.google.com with SMTP id u201so167512455oie.0
        for <netdev@vger.kernel.org>; Mon, 11 Jul 2016 14:53:35 -0700 (PDT)
In-Reply-To: <1468272598-21390-1-git-send-email-bblanco@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 12, 2016 at 12:29 AM, Brenden Blanco <bblanco@plumgrid.com> wrote:

> v7:
[...]
>  TODOs:
>  Add ethtool per-ring stats for aborted, default cases, maybe even drop
>  and tx as well.

please no... lets stop and think if we can have something better vs
every XDP enabled driver to have bunch of new ethtool based stats, was
this somehow discussed over the threads so far?
