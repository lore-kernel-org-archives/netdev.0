From: Felipe W Damasio <felipewd@gmail.com>
Subject: Re: [PATCH] tproxy: nf_tproxy_assign_sock() can handle tw sockets
Date: Tue, 13 Jul 2010 11:24:58 -0300
Message-ID: <AANLkTimn9x17g-4K7fS4MjmCgzHuBARurEoFVd_gId7m@mail.gmail.com>
References: <AANLkTimn8A0cYZmwNZYitRkBHKKFe4HQ5GU626DLugkk@mail.gmail.com>
	<AANLkTil49m6Ul2bauiH4Pwn-6ykrYTFmSO6_SxqQgD_e@mail.gmail.com>
	<1278626921.2435.73.camel@edumazet-laptop>
	<AANLkTiliBClahTfb41M5BDi1etg5pgkqEz_VfGrn_mK4@mail.gmail.com>
	<1278695580.2696.55.camel@edumazet-laptop>
	<AANLkTil39xHOhcdAo4h_jWtx_UuYdFHGdQVAdwPMd7QJ@mail.gmail.com>
	<1278742649.2538.17.camel@edumazet-laptop>
	<4C395459.6080407@redhat.com>
	<1278835332.2538.51.camel@edumazet-laptop>
	<AANLkTikEGuFtTlIKUfti6GDsdBz99PpKRCs5lEeEM86u@mail.gmail.com>
	<AANLkTilbEkJWPqvJE72r9HdFQSU84S02BKZB0CH-8QwB@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Avi Kivity <avi@redhat.com>, David Miller <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>,
	linux-kernel@vger.kernel.org, netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <AANLkTilbEkJWPqvJE72r9HdFQSU84S02BKZB0CH-8QwB@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Mr. Dumazet,

2010/7/12 Felipe W Damasio <felipewd@gmail.com>:
> Here's the result using ethtool-2.6.34:
>
> ./ethtool -k eth1
>
> Offload parameters for eth1:
> rx-checksumming: on
> tx-checksumming: on
> scatter-gather: on
> tcp-segmentation-offload: on
> udp-fragmentation-offload: off
> generic-segmentation-offload: on
> generic-receive-offload: off
> large-receive-offload: off
> ntuple-filters: off
> receive-hashing: off
>
>
> ./ethtool -k eth2
>
> Offload parameters for eth2:
> rx-checksumming: on
> tx-checksumming: on
> scatter-gather: on
> tcp-segmentation-offload: on
> udp-fragmentation-offload: off
> generic-segmentation-offload: on
> generic-receive-offload: off
> large-receive-offload: off
> ntuple-filters: off
> receive-hashing: off

Did these help you track down the issue?

Sorry to insist, it's just that my bosses are kind of pressuring me to
solve the problem and put the squid machine back online :-)

Is there a test I can run to try and trigger the issue?

I have the same scenario (hardware and network setup) on my lab...

Cheers,

Felipe Damasio
