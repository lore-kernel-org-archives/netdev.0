From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: Wrong UIDs reported in /proc/net/tcp
Date: Fri, 19 Nov 2004 10:40:58 +1100
Message-ID: <20041118234057.GA10475@gondor.apana.org.au>
References: <20041118220719.GA9890@gondor.apana.org.au> <OFE512064F.DBA4A3CD-ON88256F50.007A2A62-88256F50.007A5E0F@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Chad N. Tindel" <chad@tindel.net>, linux-net@vger.kernel.org,
        netdev@oss.sgi.com, netdev-bounce@oss.sgi.com,
        Stephen Hemminger <shemminger@osdl.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: David Stevens <dlstevens@us.ibm.com>
Content-Disposition: inline
In-Reply-To: <OFE512064F.DBA4A3CD-ON88256F50.007A2A62-88256F50.007A5E0F@us.ibm.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, Nov 18, 2004 at 02:16:33PM -0800, David Stevens wrote:
> 
> Assuming so, another solution would be to stat/fstat the file, add some to 
> it to account
> for growth, allocate a buffer that big and read the whole thing in one 
> shot. Then the
> results should be self-consistent.

You can read at most one page at a time for a /proc file.
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
