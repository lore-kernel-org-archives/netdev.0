From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH net-next 1/2] net: filter: split filter.c into two files
Date: Wed, 23 Jul 2014 08:26:30 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D1727BEC0@AcuExch.aculab.com>
References: <1406095319-3627-1-git-send-email-ast@plumgrid.com>
 <1406095319-3627-2-git-send-email-ast@plumgrid.com>
 <53CF522E.9090408@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: Ingo Molnar <mingo@kernel.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: 'Varka Bhadram' <varkabhadram@gmail.com>,
	Alexei Starovoitov <ast@plumgrid.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <53CF522E.9090408@gmail.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Varka Bhadram
> On 07/23/2014 11:31 AM, Alexei Starovoitov wrote:
> > BPF is used in several kernel components. This split creates logical boundary
> > between generic eBPF core and the rest
> >
> > kernel/bpf/core.c: eBPF interpreter
> >
> > net/core/filter.c: classic->eBPF converter, classic verifiers, socket filters
> >
> > This patch only moves functions.
> 
> If we are moving the code also its good to do cleanup.

Except you need to do it as a separate patch.

	David

> Run checkpatch.pl on this...
> 
> 
> --
> Regards,
> Varka Bhadram.
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
