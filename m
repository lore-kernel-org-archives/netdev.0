From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: Timeline of IPoIB performance
Date: Thu, 13 Oct 2005 11:48:14 +1000
Message-ID: <20051013014814.GA3688@gondor.apana.org.au>
References: <E1EPIxF-0001Cp-00@gondolin.me.apana.org.au>
	<52mzle7k2i.fsf@cisco.com> <1129141706.13945.509.camel@localhost>
	<1129166672.13948.530.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, openib-general@openib.org
Return-path: <openib-general-bounces@openib.org>
To: Matt Leininger <mlleinin@hpcn.ca.sandia.gov>
Content-Disposition: inline
In-Reply-To: <1129166672.13948.530.camel@localhost>
List-Unsubscribe: <http://openib.org/mailman/listinfo/openib-general>,
	<mailto:openib-general-request@openib.org?subject=unsubscribe>
List-Archive: <http://openib.org/pipermail/openib-general>
List-Post: <mailto:openib-general@openib.org>
List-Help: <mailto:openib-general-request@openib.org?subject=help>
List-Subscribe: <http://openib.org/mailman/listinfo/openib-general>,
	<mailto:openib-general-request@openib.org?subject=subscribe>
Sender: openib-general-bounces@openib.org
Errors-To: openib-general-bounces@openib.org
List-Id: netdev.vger.kernel.org

On Wed, Oct 12, 2005 at 06:24:32PM -0700, Matt Leininger wrote:
> 
>   Is it still worth testing the TSO patches that Herbert suggested for
> some of the 2.6.13-rc kernels?

If you're still seeing a performance regression compared to 
2.6.12-rc4, then yes (According to the figures in your message
there does seem to be a bit of loss after the release of 2.6.12).

The patch you reverted may degrade the performance on the receiver.
The TSO patches may be causing some degradation on your sender.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
