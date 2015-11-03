From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH -stable 3.18, backport] ipmr: fix possible race
 resulting from improper usage of IP_INC_STATS_BH() in preemptible context.
Date: Mon, 02 Nov 2015 16:50:11 -0800
Message-ID: <1446511811.23275.37.camel@edumazet-glaptop2.roam.corp.google.com>
References: <alpine.OSX.2.00.1511021633400.6869@animac.local>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Sasha Levin <sasha.levin@oracle.com>, stable@vger.kernel.org,
	netdev@vger.kernel.org, Eric Dumazet <edumazet@google.com>
To: Ani Sinha <ani@arista.com>
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <alpine.OSX.2.00.1511021633400.6869@animac.local>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2015-11-02 at 16:40 -0800, Ani Sinha wrote:
> [ Upstream commit 44f49dd8b5a606870a1f2 ] 

Please carefully read Documentation/networking/netdev-FAQ.txt

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
