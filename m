From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH] x86: bpf_jit_comp: Remove inline from static function definitions
Date: Thu, 4 Dec 2014 17:21:01 -0800
Message-ID: <CAADnVQ+5T3MDiC7RwVwdyu2PEhGy0VOrp7=LWeENrX_USXevnw@mail.gmail.com>
References: <CAADnVQKtYkKtsd9rUFm2yfMoh7F_SRFPVP8hpvSY00KpmB-NNg@mail.gmail.com>
	<1417734048.2721.22.camel@perches.com>
	<1417734891.22424.2.camel@edumazet-glaptop2.roam.corp.google.com>
	<CAADnVQ+3jiYOYReRLPUsFeG1p66ezo-TXBLX3BGQQh7V8QX0tQ@mail.gmail.com>
	<1417740382.22424.40.camel@edumazet-glaptop2.roam.corp.google.com>
	<1417741284.2721.26.camel@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
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
To: Joe Perches <joe@perches.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1417741284.2721.26.camel@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Dec 4, 2014 at 5:01 PM, Joe Perches <joe@perches.com> wrote:
> Let the compiler decide instead.
>
> No change in object size x86-64 -O2 no profiling
>
> Signed-off-by: Joe Perches <joe@perches.com>
> Suggested-by: Eric Dumazet <eric.dumazet@gmail.com>

Acked-by: Alexei Starovoitov <ast@plumgrid.com>

Dave, this is on top of previous patch:
http://patchwork.ozlabs.org/patch/417960/

Joe, please mention dependencies next time.
