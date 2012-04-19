From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH net-next] netfilter: nf_conntrack.h: use this_cpu_inc()
Date: Thu, 19 Apr 2012 20:16:00 +0200
Message-ID: <20120419181600.GA17878@1984>
References: <1334723800.2472.88.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	Christoph Lameter <cl@linux.com>, Tejun Heo <tj@kernel.org>,
	Patrick McHardy <kaber@trash.net>,
	Netfilter Development Mailing list
	<netfilter-devel@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1334723800.2472.88.camel@edumazet-glaptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Apr 18, 2012 at 06:36:40AM +0200, Eric Dumazet wrote:
> From: Eric Dumazet <edumazet@google.com>
> 
> this_cpu_inc() is IRQ safe and faster than
> local_bh_disable()/__this_cpu_inc()/local_bh_enable(), at least on x86.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Cc: Patrick McHardy <kaber@trash.net>
> Cc: Christoph Lameter <cl@linux.com>
> Cc: Tejun Heo <tj@kernel.org>

Applied, thanks.
