From: Linus Torvalds <torvalds@osdl.org>
Subject: Re: [bk patches] 2.6.x net driver updates
Date: Fri, 26 Sep 2003 22:20:21 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0309262217350.1863-100000@home.osdl.org>
References: <20030926010218.GA32679@gtf.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <20030926010218.GA32679@gtf.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



Hmm.. "make allyesconfig" is broken again:

	drivers/net/hamradio/baycom_epp.c:1447: conflicting types for `baycom_epp_setup'
	drivers/net/hamradio/baycom_epp.c:1359: previous declaration of `baycom_epp_setup'

and

	drivers/net/sk98lin/skdim.c: In function `GetCurrentSystemLoad':
	drivers/net/sk98lin/skdim.c:322: `smp_num_cpus' undeclared (first use in this function)
	drivers/net/sk98lin/skdim.c:322: (Each undeclared identifier is reported only once
	drivers/net/sk98lin/skdim.c:322: for each function it appears in.)
	drivers/net/sk98lin/skdim.c:322: warning: unused variable `SKNumCpus'

Pls fix,

		Linus
