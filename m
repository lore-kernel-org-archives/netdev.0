From: Arnaldo Carvalho de Melo <acme@conectiva.com.br>
Subject: Re: [patch] net/core/flow.c
Date: Mon, 17 Nov 2003 13:38:47 -0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031117153847.GB19880@conectiva.com.br>
References: <16312.59172.153904.436145@gargle.gargle.HOWL>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@redhat.com>, kuznet@ms2.inr.ac.ru,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jes Sorensen <jes@trained-monkey.org>
Content-Disposition: inline
In-Reply-To: <16312.59172.153904.436145@gargle.gargle.HOWL>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Em Mon, Nov 17, 2003 at 10:20:04AM -0500, Jes Sorensen escreveu:
> Hi Dave and Alexey,
> 
> While browsing some of the net dev code I noticed that net/core/flow.c
> still uses an unsigned long and test_bit/set_bit for it's cpu mask
> instead of cpumask_t.
> 
> Patch against 2.6.0-test9 included.

Already in latest linus bk tree, see changeset 1.1414.4.2.

- Arnaldo
