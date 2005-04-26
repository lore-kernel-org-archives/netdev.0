From: "Yair Itzhaki" <Yair@arx.com>
Subject: RE: Re-routing packets via netfilter (ip_rt_bug)
Date: Tue, 26 Apr 2005 17:39:31 +0200
Message-ID: <4151C0F9B9C25C47B3328922A6297A3286CFA9@post.arx.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: <linux-kernel@vger.kernel.org>,
	<netfilter-devel@lists.netfilter.org>, <netdev@oss.sgi.com>
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S261411AbVDZOhn@vger.kernel.org>
Content-class: urn:content-classes:message
To: "Herbert Xu" <herbert@gondor.apana.org.au>,
	"Patrick McHardy" <kaber@trash.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I'm afraid I'm not following you.
Where did you want to set saddr=0 ?

Yair


> -----Original Message-----
> From: Herbert Xu [mailto:herbert@gondor.apana.org.au]
> Sent: Tuesday, April 26, 2005 02:39
> To: Patrick McHardy
> Cc: Yair Itzhaki; linux-kernel@vger.kernel.org; 
> netfilter-devel@lists.netfilter.org; netdev@oss.sgi.com
> Subject: Re: Re-routing packets via netfilter (ip_rt_bug)
> 
> 
> On Tue, Apr 26, 2005 at 02:08:18AM +0200, Patrick McHardy wrote:
> > Herbert Xu wrote:
> > >You're right.  But then we can't call ip_route_output in the case
> > >where saddr is foreign but daddr is local.  Nor can we call
> > >ip_route_input since the output will be ip_rt_bug.
> > 
> > In that case we need to use saddr=0, which shouldn't make 
> any difference
> > with sane routing.
> 
> Makes sense.  But what about the case where saddr is foreign but
> daddr is broadcast/multicast?
> 
> Cheers,
> -- 
> Visit Openswan at http://www.openswan.org/
> Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
> Home Page: http://gondor.apana.org.au/~herbert/
> PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
> 
