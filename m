From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [ofa-general] NetEffect, iw_nes and kernel warning
Date: Tue, 21 Apr 2009 20:50:08 +0800
Message-ID: <20090421125008.GA18493@gondor.apana.org.au>
References: <20090130065721.GA4886@gondor.apana.org.au>
	<adaiqnwr91j.fsf@cisco.com>
	<20090130.135107.116108989.davem@davemloft.net>
	<ada3af0qgez.fsf@cisco.com>
	<20090421090918.GA6034@mail.wantstofly.org>
	<20090421124919.GA18444@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Roland Dreier <rdreier@cisco.com>,
	aluno3@poczta.onet.pl, David Miller <davem@davemloft.net>,
	general@lists.openfabrics.org
To: Lennert Buytenhek <buytenh@wantstofly.org>
Return-path: <general-bounces@lists.openfabrics.org>
Content-Disposition: inline
In-Reply-To: <20090421124919.GA18444@gondor.apana.org.au>
List-Unsubscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=unsubscribe>
List-Archive: <http://lists.openfabrics.org/pipermail/general>
List-Post: <mailto:general@lists.openfabrics.org>
List-Help: <mailto:general-request@lists.openfabrics.org?subject=help>
List-Subscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=subscribe>
Sender: general-bounces@lists.openfabrics.org
Errors-To: general-bounces@lists.openfabrics.org
List-Id: netdev.vger.kernel.org

On Tue, Apr 21, 2009 at 08:49:19PM +0800, Herbert Xu wrote:
> 
> I don't think the issue here is the leak.  Calling skb_linearize is
> simply illegal if you support netpoll because netpoll will call the
> xmit routine with IRQs off.

On the other hand if netpoll never generates a packet that requires
linearisation, maybe it will work :)
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
