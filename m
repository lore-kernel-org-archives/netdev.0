From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Optimizing instruction-cache, more packets at each stage
Date: Tue, 02 Feb 2016 08:37:33 -0800
Message-ID: <1454431053.7627.197.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20160115142223.1e92be75@redhat.com>
	 <20160115.154721.458450438918273509.davem@davemloft.net>
	 <20160118112703.6eac71ca@redhat.com>
	 <20160118.112455.212265265553435873.davem@davemloft.net>
	 <CAJ3xEMiOAdu7ghRoc6ZEMG78Z9xyh1M=5Egc3ydh+97bT3_9fw@mail.gmail.com>
	 <1453330945.1223.329.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CALx6S34H67o64q3YoYiHQ+VSSuSsuSjBXmexSSXF_Hq8fcN0iw@mail.gmail.com>
	 <CAJ3xEMhRUh+vtXPKeJbBQt6hV1ySxBEDhiO2e8wOK4zXi4TAzQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Tom Herbert <tom@herbertland.com>,
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
To: Or Gerlitz <gerlitz.or@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f171.google.com ([209.85.192.171]:35260 "EHLO
	mail-pf0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751769AbcBBQhg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Feb 2016 11:37:36 -0500
Received: by mail-pf0-f171.google.com with SMTP id 65so107820984pfd.2
        for <netdev@vger.kernel.org>; Tue, 02 Feb 2016 08:37:36 -0800 (PST)
In-Reply-To: <CAJ3xEMhRUh+vtXPKeJbBQt6hV1ySxBEDhiO2e8wOK4zXi4TAzQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2016-02-02 at 18:13 +0200, Or Gerlitz wrote:

> Could you provide some details on the weaknesses of Toeplitz?
> FYI, the admin is able to configure non-default keys for Toeplitz
> through ethtool.

Well, Toeplitz keys are no longer default anyway, I hope.

d682d2bdc306 bnx2x: byte swap rss_key to comply to Toeplitz specs
4671fc6d47e0 net/mlx4_en: really allow to change RSS key
c33d23c21501 enic: use netdev_rss_key_fill() helper
6bf79cdddd50 vmxnet3: use netdev_rss_key_fill() helper
7a20db379ce7 sfc: use netdev_rss_key_fill() helper
b9d1ab7eb42e mlx4: use netdev_rss_key_fill() helper
9913c61c4486 ixgbe: use netdev_rss_key_fill() helper
eb31f8493eee igb: use netdev_rss_key_fill() helper
22f258a1cc2f i40e: use netdev_rss_key_fill() helper
c41a4fba4a22 fm10k: use netdev_rss_key_fill() helper
5c8d19da9508 e100e: use netdev_rss_key_fill() helper
1dcf7b1c5f57 be2net:use netdev_rss_key_fill() helper
0fa6aa4ac4e0 bna: use netdev_rss_key_fill() helper
396483564409 tg3: use netdev_rss_key_fill() helper
e3ec69ca80a2 bnx2x: use netdev_rss_key_fill() helper
b23063034f11 amd-xgbe: use netdev_rss_key_fill() helper
960fb622f851 net: provide a per host RSS key generic infrastructure
