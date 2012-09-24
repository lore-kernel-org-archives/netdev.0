From: Dave Jones <davej@redhat.com>
Subject: Re: kernel BUG at kernel/timer.c:748!
Date: Mon, 24 Sep 2012 14:11:52 -0400
Message-ID: <20120924181152.GA31183@redhat.com>
References: <20120914212958.GA25053@redhat.com>
 <CAK6E8=cAOTqOzrzWCG=_wcQkWKS4bKh1HJ0UAH2vJNqvDPh+GQ@mail.gmail.com>
 <20120919211059.GA10985@redhat.com>
 <1348092082.31352.51.camel@edumazet-glaptop>
 <20120920020223.GA28110@redhat.com>
 <20120924153921.GA13845@redhat.com>
 <1348504445.26828.1131.camel@edumazet-glaptop>
 <1348506011.26828.1195.camel@edumazet-glaptop>
 <20120924171152.GA26454@redhat.com>
 <1348507878.26828.1271.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Yuchung Cheng <ycheng@google.com>, Julian Anastasov <ja@ssi.bg>,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:63204 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757174Ab2IXSME (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 24 Sep 2012 14:12:04 -0400
Content-Disposition: inline
In-Reply-To: <1348507878.26828.1271.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Sep 24, 2012 at 07:31:18PM +0200, Eric Dumazet wrote:
 > On Mon, 2012-09-24 at 13:11 -0400, Dave Jones wrote:
 > 
 > > Great, I'll give this a shot.
 > > 
 > > Any idea why this only just started triggering ?
 > > (Ie, do we need this for stable too?)
 > 
 > Seems this is a very old bug.

Indeed. As far as I can tell, this goes back to 2.1.8,
back in November 1996.

 > I guess your trinity tool gets better ?

Possible. Or it may be that it was finding other bugs first
that are now fixed, that prevented us getting far enough along
to try this.

 > I used following program to trigger the bug :

I'm sure reproducers like that will be appreciated by anyone
running QA tests on older kernels.

tangent: Is there any kind of networking correctness suite
other than fuzz testers like isic etc ? 

thanks,

	Dave
