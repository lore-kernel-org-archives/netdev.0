From: Martin KaFai Lau <kafai@fb.com>
Subject: Re: [PATCH net] ipv6: Don't call with rt6_uncached_list_flush_dev
Date: Mon, 12 Oct 2015 17:02:21 -0700
Message-ID: <20151013000221.GD88112@canlin-mbp1.DHCP.thefacebook.com>
References: <CACT4Y+a3J5sgSk7OvzdG6vg2PuFfBPpuJHo3csKpox5s77H+rA@mail.gmail.com>
 <1444652652.27760.158.camel@edumazet-glaptop2.roam.corp.google.com>
 <87wpusoz27.fsf_-_@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: David Miller <davem@davemloft.net>,
	Dmitry Vyukov <dvyukov@google.com>, <kuznet@ms2.inr.ac.ru>,
	<jmorris@namei.org>, <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>, <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	<syzkaller@googlegroups.com>, Kostya Serebryany <kcc@google.com>,
	Alexander Potapenko <glider@google.com>,
	Andrey Konovalov <andreyknvl@google.com>,
	Sasha Levin <sasha.levin@oracle.com>,
	Eric Dumazet <edumazet@google.com>,
	Maciej =?utf-8?Q?=C5=BBenczykowski?= <maze@google.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <87wpusoz27.fsf_-_@x220.int.ebiederm.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Oct 12, 2015 at 11:02:08AM -0500, Eric W. Biederman wrote:
>
> As originally written rt6_uncached_list_flush_dev makes no sense when
> called with dev == NULL as it attempts to flush all uncached routes
> regardless of network namespace when dev == NULL.  Which is simply
> incorrect behavior.
Thanks for fixing it.

Reviewed-by: Martin KaFai Lau <kafai@fb.com>

I also tested the following cases with the presence of DST_NOCACHE entries:
1. rmmod e1000.ko while running netperf
2. unshare(CLONE_NEWNET) as reported by Dmitry

Tested-by: Martin KaFai Lau <kafai@fb.com>
