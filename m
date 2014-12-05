From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] x86: bpf_jit_comp: Reduce is_ereg() code size
Date: Thu, 04 Dec 2014 16:46:22 -0800
Message-ID: <1417740382.22424.40.camel@edumazet-glaptop2.roam.corp.google.com>
References: <CAADnVQKtYkKtsd9rUFm2yfMoh7F_SRFPVP8hpvSY00KpmB-NNg@mail.gmail.com>
	 <1417734048.2721.22.camel@perches.com>
	 <1417734891.22424.2.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CAADnVQ+3jiYOYReRLPUsFeG1p66ezo-TXBLX3BGQQh7V8QX0tQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Joe Perches <joe@perches.com>,
	Quentin Lambert <lambert.quentin@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@redhat.com>,
	"H. Peter Anvin" <hpa@zytor.com>,
	"x86@kernel.org" <x86@kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f172.google.com ([209.85.223.172]:36624 "EHLO
	mail-ie0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754215AbaLEAqZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Dec 2014 19:46:25 -0500
In-Reply-To: <CAADnVQ+3jiYOYReRLPUsFeG1p66ezo-TXBLX3BGQQh7V8QX0tQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2014-12-04 at 15:31 -0800, Alexei Starovoitov wrote:

> well, it is a trivial function even from compiler point of view.
> Dropping inline keyword doesn't help. gcc still inlines them.
> Changing all 3 functions to _noinline_ doesn't help either.
> So I think this patch is actually quite helpful to reduce code size.

Well, again this might depend on CONFIG_CC_OPTIMIZE_FOR_SIZE

I guess people trying to get very small kernels are using this option.

My point was : If we care about code size, we should also remove these
inline keywords at the same time, to increase SNR of netdev/lkml lists.
