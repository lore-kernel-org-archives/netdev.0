From: Evgeniy Polyakov <zbr@ioremap.net>
Subject: Re: [PATCH v2] tcp: splice as many packets as possible at once
Date: Tue, 3 Feb 2009 16:06:06 +0300
Message-ID: <20090203130606.GA25471@ioremap.net>
References: <20090202080855.GA4129@ff.dom.local> <20090202.001854.261399333.davem@davemloft.net> <20090202084358.GB4129@ff.dom.local> <20090202.235017.253437221.davem@davemloft.net> <20090203094108.GA4639@ff.dom.local> <20090203111012.GA16878@ioremap.net> <20090203123628.GB4639@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, herbert@gondor.apana.org.au,
	w@1wt.eu, dada1@cosmosbay.com, ben@zeus.com, mingo@elte.hu,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	jens.axboe@oracle.com
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754922AbZBCNGb@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20090203123628.GB4639@ff.dom.local>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Feb 03, 2009 at 12:36:28PM +0000, Jarek Poplawski (jarkao2@gmail.com) wrote:
> I understand NTA could be better than slabs in above-mentioned cases,
> but I'm not sure you explaind enough your point on solving this
> zero-copy problem vs. NTA?

NTA steals pages from the SLAB so we can maintain any reference counter
logic in them, so linear part of the skb may be not really freed/reused
until reference counter hits zero.

-- 
	Evgeniy Polyakov
