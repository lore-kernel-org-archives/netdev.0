From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: Wrong UIDs reported in /proc/net/tcp
Date: Fri, 19 Nov 2004 09:07:19 +1100
Message-ID: <20041118220719.GA9890@gondor.apana.org.au>
References: <20041109205358.GA64015@calma.pair.com> <E1CRdBr-0001P2-00@gondolin.me.apana.org.au> <20041118190257.GA7084@calma.pair.com> <20041118210307.GA9557@gondor.apana.org.au> <20041118132700.29c23d00@zqx3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Chad N. Tindel" <chad@tindel.net>, netdev@oss.sgi.com,
        linux-net@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
Content-Disposition: inline
In-Reply-To: <20041118132700.29c23d00@zqx3.pdx.osdl.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, Nov 18, 2004 at 01:27:00PM -0800, Stephen Hemminger wrote:
> 
> It could also be the sockets are shared between processes with uid's or that
> the real/effective uid or different or even the uid is that of the original
> creator and the file was inherited across exec.

You're right.  However, I think the original poster is getting
different results between calls on the same connection.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
