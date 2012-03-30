From: Matt Evans <matt@ozlabs.org>
Subject: Re: [REGRESSION][PATCH] bpf_jit drops the ball on indirect negative mem references
Date: Fri, 30 Mar 2012 16:24:13 +0100
Message-ID: <5DA7DE7D-EF85-4EF6-9E31-5AD7D75274D8@ozlabs.org>
References: <CAPwCz79wO=5zTZmCG+ePfRuEu-p_Vosi18bYZ-MVNZGOdbE3aQ@mail.gmail.com> <1332965129.2325.12.camel@edumazet-glaptop> <CAPwCz7_tnjq32duJSDj21LpRe5TFvGGszH4joQr1DGTjNd7GcA@mail.gmail.com> <1332967172.2325.22.camel@edumazet-glaptop> <4F744D58.3070009@googlemail.com> <1333098711.19659.9.camel@edumazet-laptop> <4F75B828.3090705@googlemail.com> <1333116493.2325.2125.camel@edumazet-glaptop>
Mime-Version: 1.0 (1.0)
Content-Type: text/plain;
	charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Jan Seiffert <kaffeemonster@googlemail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:39547 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751269Ab2C3PYa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 30 Mar 2012 11:24:30 -0400
In-Reply-To: <1333116493.2325.2125.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Howdy Eric,

On 30 Mar 2012, at 15:08, Eric Dumazet <eric.dumazet@gmail.com> wrote:

> On Fri, 2012-03-30 at 15:42 +0200, Jan Seiffert wrote:
> 
>> Do you know where i can ping the powerpc guys a little bit harder?
> 
> maybe using CC linux-arch@vger.kernel.org
> 
> One way to handle that would be to split this patch in 3 parts, so that
> I can Ack the non ppc part.
> 
> [1] introduce bpf_internal_load_pointer_neg_helper()
>    [BTW no need to EXPORT_SYMBOL it, since jit is not a module ]
> 
> [2] x86_bpf_iit: handle negative offsets in loads
> 
> [3] ppc_bpf_jit: handle negative offsets in loads

Yeah, that'd be great, then I can stew on it without holding you up further. 

Cheers,

Matt



> 
> 
