From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] kthread: NUMA aware kthread_create_on_cpu()
Date: Mon, 29 Nov 2010 10:38:52 +0100
Message-ID: <1291023532.3435.29.camel@edumazet-laptop>
References: <1290972833.29196.90.camel@edumazet-laptop>
	 <20101128224024.GA12300@basil.fritz.box>
	 <1290984712.29196.100.camel@edumazet-laptop>
	 <20101128230146.GB12300@basil.fritz.box>
	 <1290987424.29196.128.camel@edumazet-laptop>
	 <20101129090510.GA15763@basil.fritz.box>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Andrew Morton <akpm@linux-foundation.org>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>, Tejun Heo <tj@kernel.org>,
	Rusty Russell <rusty@rustcorp.com.au>
To: Andi Kleen <andi@firstfloor.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20101129090510.GA15763@basil.fritz.box>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le lundi 29 novembre 2010 =C3=A0 10:05 +0100, Andi Kleen a =C3=A9crit :
> On Mon, Nov 29, 2010 at 12:37:04AM +0100, Eric Dumazet wrote:

> > Hmm, I meant stack (the thing that might be trashed a lot in ksofti=
rqd),
> > so it is included in struct thread_info
>=20
> task_struct is quite hot too. Also your original mail said
> task struct i believe.
>=20
> > And got correct stacks. Are you sure we must use PREFERRED ?
>=20
> Yes.

I'll respin a patch not using mempolicy but direct node, for both
thread_info and task_struct allocations.
