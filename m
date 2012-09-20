From: Dave Jones <davej@redhat.com>
Subject: Re: kernel BUG at kernel/timer.c:748!
Date: Wed, 19 Sep 2012 22:02:23 -0400
Message-ID: <20120920020223.GA28110@redhat.com>
References: <20120905043523.GA12988@redhat.com>
 <alpine.LFD.2.00.1209052343110.2201@ja.ssi.bg>
 <20120914212958.GA25053@redhat.com>
 <CAK6E8=cAOTqOzrzWCG=_wcQkWKS4bKh1HJ0UAH2vJNqvDPh+GQ@mail.gmail.com>
 <20120919211059.GA10985@redhat.com>
 <1348092082.31352.51.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Yuchung Cheng <ycheng@google.com>, Julian Anastasov <ja@ssi.bg>,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:12850 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753820Ab2ITCzr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 Sep 2012 22:55:47 -0400
Content-Disposition: inline
In-Reply-To: <1348092082.31352.51.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 20, 2012 at 12:01:22AM +0200, Eric Dumazet wrote:

 > I spent some time trying to track this bug, but found nothing so far.
 > 
 > The timer->function are never cleared by TCP stack at tear down, and
 > should be set before fd is installed and can be caught by other threads.
 > 
 > Most likely its a refcounting issue...
 > 
 > Following debugging patch might trigger a bug sooner ?

4 hours so far, nothing.. I'll leave it run overnight, but it doesn't seem to have
made much difference if any.

	Dave
