From: Ralph Doncaster <ralph@istop.com>
Subject: Re: Route cache performance tests
Date: Tue, 17 Jun 2003 18:11:00 -0400 (EDT)
Sender: linux-net-owner@vger.kernel.org
Message-ID: <Pine.LNX.4.51.0306171753170.13782@ns.istop.com>
References: <20030616.160856.35828947.davem@redhat.com> <20030616232750.GD18484@netnation.com>
 <20030616234937.GE18484@netnation.com> <20030617.085921.28790392.davem@redhat.com>
 <16111.18107.699689.704597@robur.slu.se> <20030617200721.GA25773@netnation.com>
Reply-To: ralph+d@istop.com
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "netdev@oss.sgi.com" <netdev@oss.sgi.com>,
	"linux-net@vger.kernel.org" <linux-net@vger.kernel.org>
Return-path: <linux-net-owner@vger.kernel.org>
To: Simon Kirby <sim@netnation.com>
In-Reply-To: <20030617200721.GA25773@netnation.com>
List-Id: netdev.vger.kernel.org

On Tue, 17 Jun 2003, Simon Kirby wrote:

> vma      samples  %           symbol name
> c02bf730 16019    33.2014     fn_hash_lookup
> c0292b70 3882     8.04593     ip_route_input_slow
> c0221710 2335     4.83958     tg3_rx
> c02bd550 2004     4.15354     fib_validate_source
> c0290d70 1955     4.05198     rt_hash_code
> c0294e50 1670     3.46128     ip_rcv
> c02933a0 1404     2.90997     ip_route_input

If turning off rp_filter doubles your performance, then the profile
numbers above are misleading.  My (obviously incorrect) assumption would
be that fib_validate_source is responsible for rp_filter, and turning it
off would lead to only a 5% performance increase.

Considering that, what kind of performance difference should removing the
route hashing make (i.e. going with r-trees or something like that).  In
most of the profiles fn_hash_lookup has been at the top of the list.

-Ralph

