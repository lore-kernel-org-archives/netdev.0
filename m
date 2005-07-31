From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH] Add prefetches in net/ipv4/route.c
Date: Sat, 30 Jul 2005 20:52:09 -0700 (PDT)
Message-ID: <20050730.205209.112313042.davem@davemloft.net>
References: <42EA6202.703@hp.com>
	<42EA6E0F.8060705@cosmosbay.com>
	<42EA7491.1010207@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dada1@cosmosbay.com, netdev@oss.sgi.com, davem@redhat.com,
        Robert.Olsson@data.slu.se
Return-path: <netdev-bounce@oss.sgi.com>
To: rick.jones2@hp.com
In-Reply-To: <42EA7491.1010207@hp.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

From: Rick Jones <rick.jones2@hp.com>
Date: Fri, 29 Jul 2005 11:25:21 -0700

> Which of course begs the question - what cache line size should be
> ass-u-me-d when blocking these things?  I'll put-forth 128 bytes.

Why guess?  There is no need to.

Use "__read_mostly" which is an attribute designed explicitly for
this.
