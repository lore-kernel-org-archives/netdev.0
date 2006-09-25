From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: Is TCP over IPsec broken in 2.6.18?
Date: Mon, 25 Sep 2006 16:05:19 +0400
Message-ID: <20060925120519.GA19010@2ka.mipt.ru>
References: <Pine.LNX.4.64.0609241029410.14827@d.namei> <E1GRdnS-0003kd-00@gondolin.me.apana.org.au> <20060925103836.GA13966@2ka.mipt.ru> <20060925112754.GA18228@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="vkogqOf2sHV7VnPd"
Cc: James Morris <jmorris@namei.org>, kaber@trash.net,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:23446 "EHLO 2ka.mipt.ru")
	by vger.kernel.org with ESMTP id S1750724AbWIYMFp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Sep 2006 08:05:45 -0400
To: Herbert Xu <herbert@gondor.apana.org.au>
Content-Disposition: inline
In-Reply-To: <20060925112754.GA18228@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--vkogqOf2sHV7VnPd
Content-Type: text/plain; charset=koi8-r
Content-Disposition: inline

On Mon, Sep 25, 2006 at 09:27:54PM +1000, Herbert Xu (herbert@gondor.apana.org.au) wrote:
> On Mon, Sep 25, 2006 at 02:38:36PM +0400, Evgeniy Polyakov wrote:
> > 
> > I ran two times the same 'telnet 192.168.4.79 22' and got unencrypted
> > packets and very long timeout. After some magic initial process things
> > started to work as expected - only ESP encrypted packets can be found in
> > tcpdump, until next connection is started, which becames to work not
> > correctly and then again starts to work as expected.
> 
> Perhaps something's screwed up with the policies.  Unfortunately
> the racoon logs draw a blank around the interesting interval as
> shown by the tcpdump.

I insrted blank lines specially to show where things started to work
correctly (first blank lines), second one shows where I started second 
telnet. I think you've noticed that time difference on machines
is about 30 minutes.

> Please run ip x p once every second and the post what it shows
> before, during and after the period when unecrypted packets show
> up on the wire.
> 
> You only have to do it on the 79 machine since it's the one sending
> unencrypted data.

Attached three files - before, while and after connection establishment.

-- 
	Evgeniy Polyakov

--vkogqOf2sHV7VnPd
Content-Type: text/plain; charset=koi8-r
Content-Disposition: attachment; filename=after

src 192.168.4.78/32 dst 192.168.4.79/32 
	dir in priority 2147483648 
	tmpl src 0.0.0.0 dst 0.0.0.0
		proto esp reqid 0 mode transport
src 192.168.4.79/32 dst 192.168.4.78/32 
	dir out priority 2147483648 
	tmpl src 0.0.0.0 dst 0.0.0.0
		proto esp reqid 0 mode transport
src 192.168.4.78/32 dst 192.168.4.79/32 
	dir fwd priority 2147483648 
	tmpl src 0.0.0.0 dst 0.0.0.0
		proto esp reqid 0 mode transport
src ::/0 dst ::/0 
	dir in priority 0 
src ::/0 dst ::/0 
	dir in priority 0 
src 0.0.0.0/0 dst 0.0.0.0/0 
	dir in priority 0 
src 0.0.0.0/0 dst 0.0.0.0/0 
	dir in priority 0 
src ::/0 dst ::/0 
	dir out priority 0 
src ::/0 dst ::/0 
	dir out priority 0 
src 0.0.0.0/0 dst 0.0.0.0/0 
	dir out priority 0 
src 0.0.0.0/0 dst 0.0.0.0/0 
	dir out priority 0 
src 192.168.4.78/32 dst 192.168.4.79/32 
	dir in priority 2147483648 
	tmpl src 0.0.0.0 dst 0.0.0.0
		proto esp reqid 0 mode transport
src 192.168.4.79/32 dst 192.168.4.78/32 
	dir out priority 2147483648 
	tmpl src 0.0.0.0 dst 0.0.0.0
		proto esp reqid 0 mode transport
src 192.168.4.78/32 dst 192.168.4.79/32 
	dir fwd priority 2147483648 
	tmpl src 0.0.0.0 dst 0.0.0.0
		proto esp reqid 0 mode transport
src ::/0 dst ::/0 
	dir in priority 0 
src ::/0 dst ::/0 
	dir in priority 0 
src 0.0.0.0/0 dst 0.0.0.0/0 
	dir in priority 0 
src 0.0.0.0/0 dst 0.0.0.0/0 
	dir in priority 0 
src ::/0 dst ::/0 
	dir out priority 0 
src ::/0 dst ::/0 
	dir out priority 0 
src 0.0.0.0/0 dst 0.0.0.0/0 
	dir out priority 0 
src 0.0.0.0/0 dst 0.0.0.0/0 
	dir out priority 0 
src 192.168.4.78/32 dst 192.168.4.79/32 
	dir in priority 2147483648 
	tmpl src 0.0.0.0 dst 0.0.0.0
		proto esp reqid 0 mode transport
src 192.168.4.79/32 dst 192.168.4.78/32 
	dir out priority 2147483648 
	tmpl src 0.0.0.0 dst 0.0.0.0
		proto esp reqid 0 mode transport
src 192.168.4.78/32 dst 192.168.4.79/32 
	dir fwd priority 2147483648 
	tmpl src 0.0.0.0 dst 0.0.0.0
		proto esp reqid 0 mode transport
src ::/0 dst ::/0 
	dir in priority 0 
src ::/0 dst ::/0 
	dir in priority 0 
src 0.0.0.0/0 dst 0.0.0.0/0 
	dir in priority 0 
src 0.0.0.0/0 dst 0.0.0.0/0 
	dir in priority 0 
src ::/0 dst ::/0 
	dir out priority 0 
src ::/0 dst ::/0 
	dir out priority 0 
src 0.0.0.0/0 dst 0.0.0.0/0 
	dir out priority 0 
src 0.0.0.0/0 dst 0.0.0.0/0 
	dir out priority 0 
src 192.168.4.78/32 dst 192.168.4.79/32 
	dir in priority 2147483648 
	tmpl src 0.0.0.0 dst 0.0.0.0
		proto esp reqid 0 mode transport
src 192.168.4.79/32 dst 192.168.4.78/32 
	dir out priority 2147483648 
	tmpl src 0.0.0.0 dst 0.0.0.0
		proto esp reqid 0 mode transport
src 192.168.4.78/32 dst 192.168.4.79/32 
	dir fwd priority 2147483648 
	tmpl src 0.0.0.0 dst 0.0.0.0
		proto esp reqid 0 mode transport
src ::/0 dst ::/0 
	dir in priority 0 
src ::/0 dst ::/0 
	dir in priority 0 
src 0.0.0.0/0 dst 0.0.0.0/0 
	dir in priority 0 
src 0.0.0.0/0 dst 0.0.0.0/0 
	dir in priority 0 
src ::/0 dst ::/0 
	dir out priority 0 
src ::/0 dst ::/0 
	dir out priority 0 
src 0.0.0.0/0 dst 0.0.0.0/0 
	dir out priority 0 
src 0.0.0.0/0 dst 0.0.0.0/0 
	dir out priority 0 

--vkogqOf2sHV7VnPd
Content-Type: text/plain; charset=koi8-r
Content-Disposition: attachment; filename=before

src 192.168.4.78/32 dst 192.168.4.79/32 
	dir in priority 2147483648 
	tmpl src 0.0.0.0 dst 0.0.0.0
		proto esp reqid 0 mode transport
src 192.168.4.79/32 dst 192.168.4.78/32 
	dir out priority 2147483648 
	tmpl src 0.0.0.0 dst 0.0.0.0
		proto esp reqid 0 mode transport
src 192.168.4.78/32 dst 192.168.4.79/32 
	dir fwd priority 2147483648 
	tmpl src 0.0.0.0 dst 0.0.0.0
		proto esp reqid 0 mode transport
src ::/0 dst ::/0 
	dir in priority 0 
src ::/0 dst ::/0 
	dir in priority 0 
src 0.0.0.0/0 dst 0.0.0.0/0 
	dir in priority 0 
src 0.0.0.0/0 dst 0.0.0.0/0 
	dir in priority 0 
src ::/0 dst ::/0 
	dir out priority 0 
src ::/0 dst ::/0 
	dir out priority 0 
src 0.0.0.0/0 dst 0.0.0.0/0 
	dir out priority 0 
src 0.0.0.0/0 dst 0.0.0.0/0 
	dir out priority 0 
src 192.168.4.78/32 dst 192.168.4.79/32 
	dir in priority 2147483648 
	tmpl src 0.0.0.0 dst 0.0.0.0
		proto esp reqid 0 mode transport
src 192.168.4.79/32 dst 192.168.4.78/32 
	dir out priority 2147483648 
	tmpl src 0.0.0.0 dst 0.0.0.0
		proto esp reqid 0 mode transport
src 192.168.4.78/32 dst 192.168.4.79/32 
	dir fwd priority 2147483648 
	tmpl src 0.0.0.0 dst 0.0.0.0
		proto esp reqid 0 mode transport
src ::/0 dst ::/0 
	dir in priority 0 
src ::/0 dst ::/0 
	dir in priority 0 
src 0.0.0.0/0 dst 0.0.0.0/0 
	dir in priority 0 
src 0.0.0.0/0 dst 0.0.0.0/0 
	dir in priority 0 
src ::/0 dst ::/0 
	dir out priority 0 
src ::/0 dst ::/0 
	dir out priority 0 
src 0.0.0.0/0 dst 0.0.0.0/0 
	dir out priority 0 
src 0.0.0.0/0 dst 0.0.0.0/0 
	dir out priority 0 
src 192.168.4.78/32 dst 192.168.4.79/32 
	dir in priority 2147483648 
	tmpl src 0.0.0.0 dst 0.0.0.0
		proto esp reqid 0 mode transport
src 192.168.4.79/32 dst 192.168.4.78/32 
	dir out priority 2147483648 
	tmpl src 0.0.0.0 dst 0.0.0.0
		proto esp reqid 0 mode transport
src 192.168.4.78/32 dst 192.168.4.79/32 
	dir fwd priority 2147483648 
	tmpl src 0.0.0.0 dst 0.0.0.0
		proto esp reqid 0 mode transport
src ::/0 dst ::/0 
	dir in priority 0 
src ::/0 dst ::/0 
	dir in priority 0 
src 0.0.0.0/0 dst 0.0.0.0/0 
	dir in priority 0 
src 0.0.0.0/0 dst 0.0.0.0/0 
	dir in priority 0 
src ::/0 dst ::/0 
	dir out priority 0 
src ::/0 dst ::/0 
	dir out priority 0 
src 0.0.0.0/0 dst 0.0.0.0/0 
	dir out priority 0 
src 0.0.0.0/0 dst 0.0.0.0/0 
	dir out priority 0 
src 192.168.4.78/32 dst 192.168.4.79/32 
	dir in priority 2147483648 
	tmpl src 0.0.0.0 dst 0.0.0.0
		proto esp reqid 0 mode transport
src 192.168.4.79/32 dst 192.168.4.78/32 
	dir out priority 2147483648 
	tmpl src 0.0.0.0 dst 0.0.0.0
		proto esp reqid 0 mode transport
src 192.168.4.78/32 dst 192.168.4.79/32 
	dir fwd priority 2147483648 
	tmpl src 0.0.0.0 dst 0.0.0.0
		proto esp reqid 0 mode transport
src ::/0 dst ::/0 
	dir in priority 0 
src ::/0 dst ::/0 
	dir in priority 0 
src 0.0.0.0/0 dst 0.0.0.0/0 
	dir in priority 0 
src 0.0.0.0/0 dst 0.0.0.0/0 
	dir in priority 0 
src ::/0 dst ::/0 
	dir out priority 0 
src ::/0 dst ::/0 
	dir out priority 0 
src 0.0.0.0/0 dst 0.0.0.0/0 
	dir out priority 0 
src 0.0.0.0/0 dst 0.0.0.0/0 
	dir out priority 0 
src 192.168.4.78/32 dst 192.168.4.79/32 
	dir in priority 2147483648 
	tmpl src 0.0.0.0 dst 0.0.0.0
		proto esp reqid 0 mode transport
src 192.168.4.79/32 dst 192.168.4.78/32 
	dir out priority 2147483648 
	tmpl src 0.0.0.0 dst 0.0.0.0
		proto esp reqid 0 mode transport
src 192.168.4.78/32 dst 192.168.4.79/32 
	dir fwd priority 2147483648 
	tmpl src 0.0.0.0 dst 0.0.0.0
		proto esp reqid 0 mode transport
src ::/0 dst ::/0 
	dir in priority 0 
src ::/0 dst ::/0 
	dir in priority 0 
src 0.0.0.0/0 dst 0.0.0.0/0 
	dir in priority 0 
src 0.0.0.0/0 dst 0.0.0.0/0 
	dir in priority 0 
src ::/0 dst ::/0 
	dir out priority 0 
src ::/0 dst ::/0 
	dir out priority 0 
src 0.0.0.0/0 dst 0.0.0.0/0 
	dir out priority 0 
src 0.0.0.0/0 dst 0.0.0.0/0 
	dir out priority 0 
src 192.168.4.78/32 dst 192.168.4.79/32 
	dir in priority 2147483648 
	tmpl src 0.0.0.0 dst 0.0.0.0
		proto esp reqid 0 mode transport
src 192.168.4.79/32 dst 192.168.4.78/32 
	dir out priority 2147483648 
	tmpl src 0.0.0.0 dst 0.0.0.0
		proto esp reqid 0 mode transport
src 192.168.4.78/32 dst 192.168.4.79/32 
	dir fwd priority 2147483648 
	tmpl src 0.0.0.0 dst 0.0.0.0
		proto esp reqid 0 mode transport
src ::/0 dst ::/0 
	dir in priority 0 
src ::/0 dst ::/0 
	dir in priority 0 
src 0.0.0.0/0 dst 0.0.0.0/0 
	dir in priority 0 
src 0.0.0.0/0 dst 0.0.0.0/0 
	dir in priority 0 
src ::/0 dst ::/0 
	dir out priority 0 
src ::/0 dst ::/0 
	dir out priority 0 
src 0.0.0.0/0 dst 0.0.0.0/0 
	dir out priority 0 
src 0.0.0.0/0 dst 0.0.0.0/0 
	dir out priority 0 

--vkogqOf2sHV7VnPd
Content-Type: text/plain; charset=koi8-r
Content-Disposition: attachment; filename=while

src 192.168.4.78/32 dst 192.168.4.79/32 
	dir in priority 2147483648 
	tmpl src 0.0.0.0 dst 0.0.0.0
		proto esp reqid 0 mode transport
src 192.168.4.79/32 dst 192.168.4.78/32 
	dir out priority 2147483648 
	tmpl src 0.0.0.0 dst 0.0.0.0
		proto esp reqid 0 mode transport
src 192.168.4.78/32 dst 192.168.4.79/32 
	dir fwd priority 2147483648 
	tmpl src 0.0.0.0 dst 0.0.0.0
		proto esp reqid 0 mode transport
src ::/0 dst ::/0 
	dir in priority 0 
src ::/0 dst ::/0 
	dir in priority 0 
src 0.0.0.0/0 dst 0.0.0.0/0 
	dir in priority 0 
src 0.0.0.0/0 dst 0.0.0.0/0 
	dir in priority 0 
src ::/0 dst ::/0 
	dir out priority 0 
src ::/0 dst ::/0 
	dir out priority 0 
src 0.0.0.0/0 dst 0.0.0.0/0 
	dir out priority 0 
src 0.0.0.0/0 dst 0.0.0.0/0 
	dir out priority 0 
src 192.168.4.78/32 dst 192.168.4.79/32 
	dir in priority 2147483648 
	tmpl src 0.0.0.0 dst 0.0.0.0
		proto esp reqid 0 mode transport
src 192.168.4.79/32 dst 192.168.4.78/32 
	dir out priority 2147483648 
	tmpl src 0.0.0.0 dst 0.0.0.0
		proto esp reqid 0 mode transport
src 192.168.4.78/32 dst 192.168.4.79/32 
	dir fwd priority 2147483648 
	tmpl src 0.0.0.0 dst 0.0.0.0
		proto esp reqid 0 mode transport
src ::/0 dst ::/0 
	dir in priority 0 
src ::/0 dst ::/0 
	dir in priority 0 
src 0.0.0.0/0 dst 0.0.0.0/0 
	dir in priority 0 
src 0.0.0.0/0 dst 0.0.0.0/0 
	dir in priority 0 
src ::/0 dst ::/0 
	dir out priority 0 
src ::/0 dst ::/0 
	dir out priority 0 
src 0.0.0.0/0 dst 0.0.0.0/0 
	dir out priority 0 
src 0.0.0.0/0 dst 0.0.0.0/0 
	dir out priority 0 
src 192.168.4.78/32 dst 192.168.4.79/32 
	dir in priority 2147483648 
	tmpl src 0.0.0.0 dst 0.0.0.0
		proto esp reqid 0 mode transport
src 192.168.4.79/32 dst 192.168.4.78/32 
	dir out priority 2147483648 
	tmpl src 0.0.0.0 dst 0.0.0.0
		proto esp reqid 0 mode transport
src 192.168.4.78/32 dst 192.168.4.79/32 
	dir fwd priority 2147483648 
	tmpl src 0.0.0.0 dst 0.0.0.0
		proto esp reqid 0 mode transport
src ::/0 dst ::/0 
	dir in priority 0 
src ::/0 dst ::/0 
	dir in priority 0 
src 0.0.0.0/0 dst 0.0.0.0/0 
	dir in priority 0 
src 0.0.0.0/0 dst 0.0.0.0/0 
	dir in priority 0 
src ::/0 dst ::/0 
	dir out priority 0 
src ::/0 dst ::/0 
	dir out priority 0 
src 0.0.0.0/0 dst 0.0.0.0/0 
	dir out priority 0 
src 0.0.0.0/0 dst 0.0.0.0/0 
	dir out priority 0 
src 192.168.4.78/32 dst 192.168.4.79/32 
	dir in priority 2147483648 
	tmpl src 0.0.0.0 dst 0.0.0.0
		proto esp reqid 0 mode transport
src 192.168.4.79/32 dst 192.168.4.78/32 
	dir out priority 2147483648 
	tmpl src 0.0.0.0 dst 0.0.0.0
		proto esp reqid 0 mode transport
src 192.168.4.78/32 dst 192.168.4.79/32 
	dir fwd priority 2147483648 
	tmpl src 0.0.0.0 dst 0.0.0.0
		proto esp reqid 0 mode transport
src ::/0 dst ::/0 
	dir in priority 0 
src ::/0 dst ::/0 
	dir in priority 0 
src 0.0.0.0/0 dst 0.0.0.0/0 
	dir in priority 0 
src 0.0.0.0/0 dst 0.0.0.0/0 
	dir in priority 0 
src ::/0 dst ::/0 
	dir out priority 0 
src ::/0 dst ::/0 
	dir out priority 0 
src 0.0.0.0/0 dst 0.0.0.0/0 
	dir out priority 0 
src 0.0.0.0/0 dst 0.0.0.0/0 
	dir out priority 0 
src 192.168.4.78/32 dst 192.168.4.79/32 
	dir in priority 2147483648 
	tmpl src 0.0.0.0 dst 0.0.0.0
		proto esp reqid 0 mode transport
src 192.168.4.79/32 dst 192.168.4.78/32 
	dir out priority 2147483648 
	tmpl src 0.0.0.0 dst 0.0.0.0
		proto esp reqid 0 mode transport
src 192.168.4.78/32 dst 192.168.4.79/32 
	dir fwd priority 2147483648 
	tmpl src 0.0.0.0 dst 0.0.0.0
		proto esp reqid 0 mode transport
src ::/0 dst ::/0 
	dir in priority 0 
src ::/0 dst ::/0 
	dir in priority 0 
src 0.0.0.0/0 dst 0.0.0.0/0 
	dir in priority 0 
src 0.0.0.0/0 dst 0.0.0.0/0 
	dir in priority 0 
src ::/0 dst ::/0 
	dir out priority 0 
src ::/0 dst ::/0 
	dir out priority 0 
src 0.0.0.0/0 dst 0.0.0.0/0 
	dir out priority 0 
src 0.0.0.0/0 dst 0.0.0.0/0 
	dir out priority 0 
src 192.168.4.78/32 dst 192.168.4.79/32 
	dir in priority 2147483648 
	tmpl src 0.0.0.0 dst 0.0.0.0
		proto esp reqid 0 mode transport
src 192.168.4.79/32 dst 192.168.4.78/32 
	dir out priority 2147483648 
	tmpl src 0.0.0.0 dst 0.0.0.0
		proto esp reqid 0 mode transport
src 192.168.4.78/32 dst 192.168.4.79/32 
	dir fwd priority 2147483648 
	tmpl src 0.0.0.0 dst 0.0.0.0
		proto esp reqid 0 mode transport
src ::/0 dst ::/0 
	dir in priority 0 
src ::/0 dst ::/0 
	dir in priority 0 
src 0.0.0.0/0 dst 0.0.0.0/0 
	dir in priority 0 
src 0.0.0.0/0 dst 0.0.0.0/0 
	dir in priority 0 
src ::/0 dst ::/0 
	dir out priority 0 
src ::/0 dst ::/0 
	dir out priority 0 
src 0.0.0.0/0 dst 0.0.0.0/0 
	dir out priority 0 
src 0.0.0.0/0 dst 0.0.0.0/0 
	dir out priority 0 
src 192.168.4.78/32 dst 192.168.4.79/32 
	dir in priority 2147483648 
	tmpl src 0.0.0.0 dst 0.0.0.0
		proto esp reqid 0 mode transport
src 192.168.4.79/32 dst 192.168.4.78/32 
	dir out priority 2147483648 
	tmpl src 0.0.0.0 dst 0.0.0.0
		proto esp reqid 0 mode transport
src 192.168.4.78/32 dst 192.168.4.79/32 
	dir fwd priority 2147483648 
	tmpl src 0.0.0.0 dst 0.0.0.0
		proto esp reqid 0 mode transport
src ::/0 dst ::/0 
	dir in priority 0 
src ::/0 dst ::/0 
	dir in priority 0 
src 0.0.0.0/0 dst 0.0.0.0/0 
	dir in priority 0 
src 0.0.0.0/0 dst 0.0.0.0/0 
	dir in priority 0 
src ::/0 dst ::/0 
	dir out priority 0 
src ::/0 dst ::/0 
	dir out priority 0 
src 0.0.0.0/0 dst 0.0.0.0/0 
	dir out priority 0 
src 0.0.0.0/0 dst 0.0.0.0/0 
	dir out priority 0 
src 192.168.4.78/32 dst 192.168.4.79/32 
	dir in priority 2147483648 
	tmpl src 0.0.0.0 dst 0.0.0.0
		proto esp reqid 0 mode transport
src 192.168.4.79/32 dst 192.168.4.78/32 
	dir out priority 2147483648 
	tmpl src 0.0.0.0 dst 0.0.0.0
		proto esp reqid 0 mode transport
src 192.168.4.78/32 dst 192.168.4.79/32 
	dir fwd priority 2147483648 
	tmpl src 0.0.0.0 dst 0.0.0.0
		proto esp reqid 0 mode transport
src ::/0 dst ::/0 
	dir in priority 0 
src ::/0 dst ::/0 
	dir in priority 0 
src 0.0.0.0/0 dst 0.0.0.0/0 
	dir in priority 0 
src 0.0.0.0/0 dst 0.0.0.0/0 
	dir in priority 0 
src ::/0 dst ::/0 
	dir out priority 0 
src ::/0 dst ::/0 
	dir out priority 0 
src 0.0.0.0/0 dst 0.0.0.0/0 
	dir out priority 0 
src 0.0.0.0/0 dst 0.0.0.0/0 
	dir out priority 0 
src 192.168.4.78/32 dst 192.168.4.79/32 
	dir in priority 2147483648 
	tmpl src 0.0.0.0 dst 0.0.0.0
		proto esp reqid 0 mode transport
src 192.168.4.79/32 dst 192.168.4.78/32 
	dir out priority 2147483648 
	tmpl src 0.0.0.0 dst 0.0.0.0
		proto esp reqid 0 mode transport
src 192.168.4.78/32 dst 192.168.4.79/32 
	dir fwd priority 2147483648 
	tmpl src 0.0.0.0 dst 0.0.0.0
		proto esp reqid 0 mode transport
src ::/0 dst ::/0 
	dir in priority 0 
src ::/0 dst ::/0 
	dir in priority 0 
src 0.0.0.0/0 dst 0.0.0.0/0 
	dir in priority 0 
src 0.0.0.0/0 dst 0.0.0.0/0 
	dir in priority 0 
src ::/0 dst ::/0 
	dir out priority 0 
src ::/0 dst ::/0 
	dir out priority 0 
src 0.0.0.0/0 dst 0.0.0.0/0 
	dir out priority 0 
src 0.0.0.0/0 dst 0.0.0.0/0 
	dir out priority 0 
src 192.168.4.78/32 dst 192.168.4.79/32 
	dir in priority 2147483648 
	tmpl src 0.0.0.0 dst 0.0.0.0
		proto esp reqid 0 mode transport
src 192.168.4.79/32 dst 192.168.4.78/32 
	dir out priority 2147483648 
	tmpl src 0.0.0.0 dst 0.0.0.0
		proto esp reqid 0 mode transport
src 192.168.4.78/32 dst 192.168.4.79/32 
	dir fwd priority 2147483648 
	tmpl src 0.0.0.0 dst 0.0.0.0
		proto esp reqid 0 mode transport
src ::/0 dst ::/0 
	dir in priority 0 
src ::/0 dst ::/0 
	dir in priority 0 
src 0.0.0.0/0 dst 0.0.0.0/0 
	dir in priority 0 
src 0.0.0.0/0 dst 0.0.0.0/0 
	dir in priority 0 
src ::/0 dst ::/0 
	dir out priority 0 
src ::/0 dst ::/0 
	dir out priority 0 
src 0.0.0.0/0 dst 0.0.0.0/0 
	dir out priority 0 
src 0.0.0.0/0 dst 0.0.0.0/0 
	dir out priority 0 
src 192.168.4.78/32 dst 192.168.4.79/32 
	dir in priority 2147483648 
	tmpl src 0.0.0.0 dst 0.0.0.0
		proto esp reqid 0 mode transport
src 192.168.4.79/32 dst 192.168.4.78/32 
	dir out priority 2147483648 
	tmpl src 0.0.0.0 dst 0.0.0.0
		proto esp reqid 0 mode transport
src 192.168.4.78/32 dst 192.168.4.79/32 
	dir fwd priority 2147483648 
	tmpl src 0.0.0.0 dst 0.0.0.0
		proto esp reqid 0 mode transport
src ::/0 dst ::/0 
	dir in priority 0 
src ::/0 dst ::/0 
	dir in priority 0 
src 0.0.0.0/0 dst 0.0.0.0/0 
	dir in priority 0 
src 0.0.0.0/0 dst 0.0.0.0/0 
	dir in priority 0 
src ::/0 dst ::/0 
	dir out priority 0 
src ::/0 dst ::/0 
	dir out priority 0 
src 0.0.0.0/0 dst 0.0.0.0/0 
	dir out priority 0 
src 0.0.0.0/0 dst 0.0.0.0/0 
	dir out priority 0 
src 192.168.4.78/32 dst 192.168.4.79/32 
	dir in priority 2147483648 
	tmpl src 0.0.0.0 dst 0.0.0.0
		proto esp reqid 0 mode transport
src 192.168.4.79/32 dst 192.168.4.78/32 
	dir out priority 2147483648 
	tmpl src 0.0.0.0 dst 0.0.0.0
		proto esp reqid 0 mode transport
src 192.168.4.78/32 dst 192.168.4.79/32 
	dir fwd priority 2147483648 
	tmpl src 0.0.0.0 dst 0.0.0.0
		proto esp reqid 0 mode transport
src ::/0 dst ::/0 
	dir in priority 0 
src ::/0 dst ::/0 
	dir in priority 0 
src 0.0.0.0/0 dst 0.0.0.0/0 
	dir in priority 0 
src 0.0.0.0/0 dst 0.0.0.0/0 
	dir in priority 0 
src ::/0 dst ::/0 
	dir out priority 0 
src ::/0 dst ::/0 
	dir out priority 0 
src 0.0.0.0/0 dst 0.0.0.0/0 
	dir out priority 0 
src 0.0.0.0/0 dst 0.0.0.0/0 
	dir out priority 0 

--vkogqOf2sHV7VnPd--
