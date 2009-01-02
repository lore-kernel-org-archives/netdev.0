From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: Fw: [Bug 12327] New: Intermittent TCP issues with => 2.6.27
Date: Fri, 2 Jan 2009 10:02:47 +0200 (EET)
Message-ID: <Pine.LNX.4.64.0901020954090.5116@wrl-59.cs.helsinki.fi>
References: <E1LIeZf-0006ET-OY@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	David Miller <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:45632 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756077AbZABICu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Jan 2009 03:02:50 -0500
In-Reply-To: <E1LIeZf-0006ET-OY@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2 Jan 2009, Herbert Xu wrote:

> Stephen Hemminger <shemminger@linux-foundation.org> wrote:
> > 
> > A number of websites, ping, traceroute work correctly but I simply can't
> > connect to several including:
> > 
> > - store.apple.com
> > - youtube.com
> > - ANZ internet banking (anz.com.au)
> > - MSN messenger
> 
> I failed to reproduce this on 2.6.28-rc9.  I even used the same
> IP address as shown in your pcap file, 17.149.156.10.

Same for me, though I don't have ppp in the setup like he does
(see the mail in the other thread).

> In fact, your pcap file shows that the two kernels produce almost
> exactly the same content in the TCP headers. The only material
> difference was the window size, which differed by 32 bytes.

Yeah, nothing wrong with tcp/ip side.

> So I'd suggest you take a look at other nodes on the path between
> you and those websites, or try turning things such as window
> scaling off.

He did already turn things off without any success, the original report 
for ubuntu is at:

https://bugs.launchpad.net/ubuntu/+source/linux/+bug/296767

I doubt that the original reporter received this mail anyway... There's 
another thread (fwd by Andrew) which has more content already.

-- 
 i.
