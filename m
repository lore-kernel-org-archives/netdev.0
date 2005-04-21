From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: Problem with IPSEC tunnel mode
Date: Fri, 22 Apr 2005 09:58:02 +1000
Message-ID: <20050421235802.GB10451@gondor.apana.org.au>
References: <E1DObFc-0000je-00@gondolin.me.apana.org.au> <200504211640.16742.wolfgang.walter@studentenwerk.mhn.de> <20050421214618.GA29991@gondor.apana.org.au> <1114127419.10572.4.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Wolfgang Walter <wolfgang.walter@studentenwerk.mhn.de>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1114127419.10572.4.camel@localhost.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, Apr 21, 2005 at 07:50:19PM -0400, jamal wrote:
> What was the reason there exist a FWD direction in the policies?

You should really ask Alexey about that :) I myself had the same
question when I first started in this area.  However, since it
has been present since the very beginning and people are already
relying on it, we will have to live with it.

> Also - shouldnt the FWD policies closely match the OUT ones instead of
> the IN direction (browsing the forwarding code)? i.e
> does this look odd to you (picking a sample from Wolfgangs output):

The FWD policies are analogous to the FORWARD table in netfilter.
The FWD policies apply to forwarded packet, meaning packets that
end up in ip_forward instead of ip_local_deliver.  The IN policies
only apply to packets that end up in ip_local_deliver.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
