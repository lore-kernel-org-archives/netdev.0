From: Jiri Kosina <jikos@kernel.org>
Subject: Re: [RFC PATCH v2] net: sched: convert qdisc linked list to
 hashtable
Date: Fri, 8 Jul 2016 10:11:26 +0200 (CEST)
Message-ID: <alpine.LNX.2.00.1607081008460.24757@cbobk.fhfr.pm>
References: <CAEfhGizOVjafBpH8K0+57cyN_ySKqChYRw8jrfV=ODM5nmnvmA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Phil Sutter <phil@nwl.cc>, netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Craig Gallek <kraigatgoog@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAEfhGizOVjafBpH8K0+57cyN_ySKqChYRw8jrfV=ODM5nmnvmA@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 7 Jul 2016, Craig Gallek wrote:

> This sort of seems like it's just side-stepping the problem.  Given
> that the size of this hash table is fixed, the lookup time of this
> operation is still going to approach linear as the number of qdiscs
> increases.  

That's true; however the primary goal here is not to actually ultimately 
improve speed of qdisc lookup per se, but rather to make it possible to 
unhide the qdiscs which are currently omitted as the linked list takes too 
long to walk. The static hashtable is going help here.

Thanks,

-- 
Jiri Kosina
SUSE Labs
