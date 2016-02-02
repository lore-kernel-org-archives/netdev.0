From: Or Gerlitz <gerlitz.or@gmail.com>
Subject: Re: Optimizing instruction-cache, more packets at each stage
Date: Tue, 2 Feb 2016 18:13:40 +0200
Message-ID: <CAJ3xEMhRUh+vtXPKeJbBQt6hV1ySxBEDhiO2e8wOK4zXi4TAzQ@mail.gmail.com>
References: <20160115142223.1e92be75@redhat.com>
	<20160115.154721.458450438918273509.davem@davemloft.net>
	<20160118112703.6eac71ca@redhat.com>
	<20160118.112455.212265265553435873.davem@davemloft.net>
	<CAJ3xEMiOAdu7ghRoc6ZEMG78Z9xyh1M=5Egc3ydh+97bT3_9fw@mail.gmail.com>
	<1453330945.1223.329.camel@edumazet-glaptop2.roam.corp.google.com>
	<CALx6S34H67o64q3YoYiHQ+VSSuSsuSjBXmexSSXF_Hq8fcN0iw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Jesper Dangaard Brouer <brouer@redhat.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Alexander Duyck <alexander.duyck@gmail.com>,
	Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	Daniel Borkmann <borkmann@iogearbox.net>,
	Marek Majkowski <marek@cloudflare.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Florian Westphal <fw@strlen.de>,
	Paolo Abeni <pabeni@redhat.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	Amir Vadai <amirva@gmail.com>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f172.google.com ([209.85.213.172]:37813 "EHLO
	mail-ig0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932281AbcBBQNl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Feb 2016 11:13:41 -0500
Received: by mail-ig0-f172.google.com with SMTP id 5so14759676igt.0
        for <netdev@vger.kernel.org>; Tue, 02 Feb 2016 08:13:41 -0800 (PST)
In-Reply-To: <CALx6S34H67o64q3YoYiHQ+VSSuSsuSjBXmexSSXF_Hq8fcN0iw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 21, 2016 at 1:27 AM, Tom Herbert <tom@herbertland.com> wrote:

> Unfortunately, the hardware hash from devices hasn't really lived up
> to its potential. The original intent of getting the hash from device
> was to be able to do packet steering (RPS and RFS) without touching
> the header. But this never was implemented. eth_type_trans touches
> headers and GRO is best when done before steering. Given the
> weaknesses of Toeplitz we talked about recently and that fact that
> Jenkins is really fast to compute, I am starting to think maybe we
> should always do a software hash and not rely on HW for it...

Could you provide some details on the weaknesses of Toeplitz?
FYI, the admin is able to configure non-default keys for Toeplitz
through ethtool.

Or.
