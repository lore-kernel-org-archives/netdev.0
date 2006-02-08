From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] ppp: don't use 0 in pointer context
Date: Thu, 09 Feb 2006 09:19:20 +1100
Message-ID: <E1F6xei-0006hc-00@gondolin.me.apana.org.au>
References: <17386.27957.822041.83512@gargle.gargle.HOWL>
Cc: adobriyan@gmail.com, viro@ftp.linux.org.uk, netdev@vger.kernel.org,
	linux-ppp@vger.kernel.org
Return-path: <linux-ppp-owner@vger.kernel.org>
To: carlsonj@workingcode.com (James Carlson)
In-Reply-To: <17386.27957.822041.83512@gargle.gargle.HOWL>
Sender: linux-ppp-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

James Carlson <carlsonj@workingcode.com> wrote:
> Alexey Dobriyan writes:
>> -     if (ap == 0)
>> +     if (!ap)
> 
> And the solution is to treat it as a boolean instead?!  I'm not sure
> which is more ugly.

Treating it as a boolean looks good to me.  It's better than the existing
code because it shuts sparse up.
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
