From: "David S. Miller" <davem@redhat.com>
Subject: Re: [IPSEC] Move hardware headers for decaped packets
Date: Sun, 7 Dec 2003 01:47:14 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031207014714.03e79cd2.davem@redhat.com>
References: <20030925121131.GA17968@gondor.apana.org.au>
	<200309251228.QAA11650@yakov.inr.ac.ru>
	<20030925124102.GA18188@gondor.apana.org.au>
	<20031207090205.GA2358@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, jmorris@redhat.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20031207090205.GA2358@gondor.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, 7 Dec 2003 20:02:05 +1100
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> So I'd like to go with the previous approach which is to move
> for tunnel SAs only by using mac_len.

Ok, I'll review this again.  Did you audit the tree to make sure you
updated mac_len everywhere that 'skb->mac.*' is modified?
