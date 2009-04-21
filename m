From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH] netfilter: use per-cpu recursive lock (v11)
Date: Tue, 21 Apr 2009 09:37:58 -0700
Message-ID: <20090421163758.GF6642@linux.vnet.ibm.com>
References: <20090417012812.GA25534@linux.vnet.ibm.com> <20090418094001.GA2369@ioremap.net> <20090418141455.GA7082@linux.vnet.ibm.com> <20090420103414.1b4c490f@nehalam> <49ECBE0A.7010303@cosmosbay.com> <18924.59347.375292.102385@cargo.ozlabs.ibm.com> <20090420215827.GK6822@linux.vnet.ibm.com> <18924.64032.103954.171918@cargo.ozlabs.ibm.com> <20090420160121.268a8226@nehalam> <49ED52B1.7050601@cosmosbay.com>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	Paul Mackerras <paulus@samba.org>,
	Evgeniy Polyakov <zbr@ioremap.net>,
	David Miller <davem@davemloft.net>, kaber@trash.net,
	torvalds@linux-foundation.org, jeff.chua.linux@gmail.com,
	mingo@elte.hu, laijs@cn.fujitsu.com, jengelh@medozas.de,
	r000n@r000n.net, linux-kernel@vger.kernel.org,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	benh@kernel.crashing.org, mathieu.desnoyers@polymtl.ca
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <49ED52B1.7050601@cosmosbay.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Apr 21, 2009 at 06:59:29AM +0200, Eric Dumazet wrote:

[ . . . ]

> Hopefully, next rcu_bh (or whatever name is used) will permit us
> to switch back to pure RCU in 2.6.31

My excursion in to rcu_fgp can be thought of as a training exercise for
doing this, though perhaps others are also working on an upgraded rcu_bh
as well.

							Thanx, Paul
