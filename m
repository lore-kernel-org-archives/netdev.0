From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [Openswan dev] ip xfrm bug
Date: Sun, 16 Dec 2007 15:43:59 +0800
Message-ID: <20071216074359.GA2800@gondor.apana.org.au>
References: <Pine.LNX.4.64.0711291131080.21906@newtla.xelerance.com>
	<20071214091659.GA16129@gondor.apana.org.au>
	<20071214112118.118862c3@deepthought>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: dev@openswan.org, netdev@vger.kernel.org, jamal <hadi@cyberus.ca>
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <dev-bounces@openswan.org>
Content-Disposition: inline
In-Reply-To: <20071214112118.118862c3@deepthought>
List-Unsubscribe: <http://lists.openswan.org/mailman/listinfo/dev>,
	<mailto:dev-request@openswan.org?subject=unsubscribe>
List-Archive: <http://lists.openswan.org/pipermail/dev>
List-Post: <mailto:dev@openswan.org>
List-Help: <mailto:dev-request@openswan.org?subject=help>
List-Subscribe: <http://lists.openswan.org/mailman/listinfo/dev>,
	<mailto:dev-request@openswan.org?subject=subscribe>
Sender: dev-bounces@openswan.org
Errors-To: dev-bounces@openswan.org
List-Id: netdev.vger.kernel.org

On Fri, Dec 14, 2007 at 11:21:18AM -0800, Stephen Hemminger wrote:
>
> I can see where to filter these, but I am ignorant of how to
> identify the socket policies. Are they just marked as sub-policies?

Jamal's going to hate me but setkey(8) already uses this so we're
stuck with it anyway.

The test is

	up->index % 8 >= 3

This is true iff it's a socket policy.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
