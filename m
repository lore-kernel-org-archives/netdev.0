From: "David S. Miller" <davem@redhat.com>
Subject: Re: [2.4 PATCH] bugfix: ARP respond on all devices
Date: Sun, 27 Jul 2003 17:55:57 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030727175557.1d624b36.davem@redhat.com>
References: <Pine.LNX.4.53.0307272239570.2743@vialle.bloemsaat.com>
	<200307280140470646.1078EC67@192.168.128.16>
	<20030727164649.517b2b88.davem@redhat.com>
	<200307280158250677.10891156@192.168.128.16>
	<20030727165831.05904792.davem@redhat.com>
	<200307280211590888.10957DD9@192.168.128.16>
	<20030727171403.6e5bcc58.davem@redhat.com>
	<200307280235210263.10AADFF8@192.168.128.16>
	<20030727173600.475d95fb.davem@redhat.com>
	<200307280253090799.10BB2DF0@192.168.128.16>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bloemsaa@xs4all.nl, marcelo@conectiva.com.br, netdev@oss.sgi.com,
   linux-net@vger.kernel.org, layes@loran.com, torvalds@osdl.org,
   linux-kernel@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: "Carlos Velasco" <carlosev@newipnet.com>
In-Reply-To: <200307280253090799.10BB2DF0@192.168.128.16>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 28 Jul 2003 02:53:09 +0200
"Carlos Velasco" <carlosev@newipnet.com> wrote:

> But if the hidden patch and /proc switch would be in the main kernel,
> it would be the simpliest way to solve all these "problems" (with an
> echo "1" and without filtering or using iproute2).

With or without your suggestion, people have to do something
different.

This doesn't even address all the problems there are with
the hidden patch.  It does things that belong on the netfilter
level and not on the ARP/routing level.

Again, I'd like you to read all the discussions that have happened on
this topic in the past, in particular those made by Alexey Kuznetsov
on this topic.  He gives very clear and concise reasons why the
"hidden" patch is logically doing things in the wrong part of the
kernel, and therefore won't ever be put into the tree.
