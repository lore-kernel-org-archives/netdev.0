From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [REGRESSION][PATCH] bpf_jit drops the ball on indirect
 negative mem references
Date: Fri, 30 Mar 2012 16:08:13 +0200
Message-ID: <1333116493.2325.2125.camel@edumazet-glaptop>
References: <CAPwCz79wO=5zTZmCG+ePfRuEu-p_Vosi18bYZ-MVNZGOdbE3aQ@mail.gmail.com>
	 <1332965129.2325.12.camel@edumazet-glaptop>
	 <CAPwCz7_tnjq32duJSDj21LpRe5TFvGGszH4joQr1DGTjNd7GcA@mail.gmail.com>
	 <1332967172.2325.22.camel@edumazet-glaptop>
	 <4F744D58.3070009@googlemail.com>
	 <1333098711.19659.9.camel@edumazet-laptop>
	 <4F75B828.3090705@googlemail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Matt Evans <matt@ozlabs.org>
To: Jan Seiffert <kaffeemonster@googlemail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4F75B828.3090705@googlemail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2012-03-30 at 15:42 +0200, Jan Seiffert wrote:

> Do you know where i can ping the powerpc guys a little bit harder?

maybe using CC linux-arch@vger.kernel.org

One way to handle that would be to split this patch in 3 parts, so that
I can Ack the non ppc part.

[1] introduce bpf_internal_load_pointer_neg_helper()
	[BTW no need to EXPORT_SYMBOL it, since jit is not a module ]

[2] x86_bpf_iit: handle negative offsets in loads

[3] ppc_bpf_jit: handle negative offsets in loads
