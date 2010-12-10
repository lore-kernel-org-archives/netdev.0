From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2 3/4] kthread: NUMA aware kthread_create_on_cpu()
Date: Fri, 10 Dec 2010 08:02:41 +0100
Message-ID: <1291964561.2803.25.camel@edumazet-laptop>
References: <1290972833.29196.90.camel@edumazet-laptop>
	 <20101128224024.GA12300@basil.fritz.box>
	 <1290984712.29196.100.camel@edumazet-laptop>
	 <20101128230146.GB12300@basil.fritz.box>
	 <1290987424.29196.128.camel@edumazet-laptop>
	 <20101129090510.GA15763@basil.fritz.box>
	 <1291023532.3435.29.camel@edumazet-laptop>
	 <1291043695.3435.980.camel@edumazet-laptop>
	 <20101209164438.fae1ba4c.akpm@linux-foundation.org>
	 <1291960798.2803.18.camel@edumazet-laptop>
	 <20101209223210.acd540de.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Andi Kleen <andi@firstfloor.org>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>, Tejun Heo <tj@kernel.org>,
	Rusty Russell <rusty@rustcorp.com.au>,
	Tony Luck <tony.luck@intel.com>,
	Fenghua Yu <fenghua.yu@intel.com>
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20101209223210.acd540de.akpm@linux-foundation.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le jeudi 09 d=C3=A9cembre 2010 =C3=A0 22:32 -0800, Andrew Morton a =C3=A9=
crit :

> but but but.  The name "kthread_create_on_cpu" sucks.  It's plain wro=
ng.

Okay you are right Andrew ;) I dont have better idea for the moment.

Note that all callers I converted really create one kthread per cpu, no=
t
per node. They didnt care of node affinity, only me :)

kthread_create_on_node() seems misleading to me (some cpus run on
memoryless nodes)
