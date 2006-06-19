From: jamal <hadi@cyberus.ca>
Subject: Re: [NET]: Prevent multiple qdisc runs
Date: Mon, 19 Jun 2006 09:33:51 -0400
Message-ID: <1150724031.5815.39.camel@jzny2>
References: <20060619121519.GA16031@gondor.apana.org.au>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx02.cybersurf.com ([209.197.145.105]:19176 "EHLO
	mx02.cybersurf.com") by vger.kernel.org with ESMTP id S932451AbWFSNdz
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 19 Jun 2006 09:33:55 -0400
Received: from mail.cyberus.ca ([209.197.145.21])
	by mx02.cybersurf.com with esmtp (Exim 4.30)
	id 1FsJt7-0000I1-LH
	for netdev@vger.kernel.org; Mon, 19 Jun 2006 09:33:57 -0400
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20060619121519.GA16031@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Herbert,

I take it you saw a lot of requeues happening that prompted this? What
were the circumstances? The _only_ times i have seen it happen is when
the (PCI) bus couldnt handle the incoming rate or there was a bug in the
driver. 
Also: what happens to the packet that comes in from either local or is
being forwarded and finds the qdisc_is_running flag is set? I couldnt
tell if the intent was to drop it or not. The answer for TCP is probably
simpler than for packets being forwarded.

cheers,
jamal


On Mon, 2006-19-06 at 22:15 +1000, Herbert Xu wrote:
> Hi Dave:
> 
> I'm nearly done with the generic segmentation offload stuff (although
> only TCPv4 is implemented for now), and I encountered this problem.
> 
> [NET]: Prevent multiple qdisc runs
> 


