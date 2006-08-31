From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: IPSec kernel oops on ppc64
Date: Thu, 31 Aug 2006 13:53:46 +1000
Message-ID: <20060831035346.GA28306@gondor.apana.org.au>
References: <200608301636.k7UGaQY5002569@faith.austin.ibm.com>
	<20060831015942.GA27423@gondor.apana.org.au>
	<17654.21983.691176.397891@cargo.ozlabs.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: jmorris@redhat.com, netdev@vger.kernel.org, anton@au1.ibm.com,
	linuxppc-dev@ozlabs.org, gcwilson@us.ibm.com,
	Joy Latten <latten@austin.ibm.com>, davem@davemloft.net
Return-path: <linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org>
To: Paul Mackerras <paulus@samba.org>
Content-Disposition: inline
In-Reply-To: <17654.21983.691176.397891@cargo.ozlabs.ibm.com>
List-Unsubscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=unsubscribe>
List-Archive: <http://ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@ozlabs.org?subject=help>
List-Subscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=subscribe>
Sender: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
Errors-To: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
List-Id: netdev.vger.kernel.org

Hi Paul:

On Thu, Aug 31, 2006 at 01:22:07PM +1000, Paul Mackerras wrote:
> 
> You missed a couple of 'beqlr' instructions (branch if equal to LR).
> I'd be interested to know if it still fails with the patch below.

Yes that'd do it.

BTW, did you see the "cmpldi r1,..." stuff in the code?  That's a typo,
right?

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
