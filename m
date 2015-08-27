From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: ip_rcv_finish() NULL pointer and possibly related Oopses
Date: Thu, 27 Aug 2015 09:30:16 -0700
Message-ID: <1440693016.8932.41.camel@edumazet-glaptop2.roam.corp.google.com>
References: <D2033B8F.4133C%Shaun.Crampton@metaswitch.com>
	 <20150826074959.48aea34c@as>
	 <CAGr1u3twv7KnXug3xZqL3X9NNpWBwGvw1RQpMHyqBmcC2ikamw@mail.gmail.com>
	 <1440680401.8932.39.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CAGr1u3vDQDj6rJYcx2vCsf9KkWf-X=qSh3QD-jAZf7hpUYaAyg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Chuck Ebbert <cebbert.lkml@gmail.com>,
	Shaun Crampton <Shaun.Crampton@metaswitch.com>,
	linux-kernel@vger.kernel.org,
	Peter White <Peter.White@metaswitch.com>,
	netdev@vger.kernel.org
To: Michael Marineau <michael.marineau@coreos.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAGr1u3vDQDj6rJYcx2vCsf9KkWf-X=qSh3QD-jAZf7hpUYaAyg@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2015-08-27 at 09:16 -0700, Michael Marineau wrote:

> 
> Oh, interesting. Looks like that patch didn't get CC'd to stable
> though, is there a reason for that or just oversight?

We never CC stable for networking patches.

David Miller prefers to take care of this himself.

( this is in Documentation/networking/netdev-FAQ.txt )

Q: How can I tell what patches are queued up for backporting to the
   various stable releases?

A: Normally Greg Kroah-Hartman collects stable commits himself, but
   for networking, Dave collects up patches he deems critical for the
   networking subsystem, and then hands them off to Greg.

   There is a patchworks queue that you can see here:
        http://patchwork.ozlabs.org/bundle/davem/stable/?state=*

   It contains the patches which Dave has selected, but not yet handed
   off to Greg.  If Greg already has the patch, then it will be here:
        http://git.kernel.org/cgit/linux/kernel/git/stable/stable-queue.git

   A quick way to find whether the patch is in this stable-queue is
   to simply clone the repo, and then git grep the mainline commit ID, e.g.

        stable-queue$ git grep -l 284041ef21fdf2e
        releases/3.0.84/ipv6-fix-possible-crashes-in-ip6_cork_release.patch
        releases/3.4.51/ipv6-fix-possible-crashes-in-ip6_cork_release.patch
        releases/3.9.8/ipv6-fix-possible-crashes-in-ip6_cork_release.patch
        stable/stable-queue$
