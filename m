From: "David S. Miller" <davem@redhat.com>
Subject: Re: [2.4 PATCH] bugfix: ARP respond on all devices
Date: Tue, 19 Aug 2003 08:57:17 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030819085717.56046afd.davem@redhat.com>
References: <353568DCBAE06148B70767C1B1A93E625EAB58@post.pc.aspectgroup.co.uk>
	<20030819145403.GA3407@alpha.home.local>
	<20030819170751.2b92ba2e.skraw@ithnet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: willy@w.ods.org, richard@aspectgroup.co.uk, alan@lxorguk.ukuu.org.uk,
   carlosev@newipnet.com, lamont@scriptkiddie.org, davidsen@tmr.com,
   bloemsaa@xs4all.nl, marcelo@conectiva.com.br, netdev@oss.sgi.com,
   linux-net@vger.kernel.org, layes@loran.com, torvalds@osdl.org,
   linux-kernel@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephan von Krawczynski <skraw@ithnet.com>
In-Reply-To: <20030819170751.2b92ba2e.skraw@ithnet.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 19 Aug 2003 17:07:51 +0200
Stephan von Krawczynski <skraw@ithnet.com> wrote:

> Hm, what rule is broken by the remote host, then?

It means that systems (like Linux) that make IP addresses owned by the
host instead of specific interfaces cannot correctly interoperate with
such remote systems.

It is also the case that a host cannot possibly be aware of all
subnets present on a given LAN, therefore is should be liberal in it's
replies to ARP requests.

Finally, it violates the most basic rule of IP networking:

"Be liberal in what you accept, and conservative in what you send"
-Jon Postel

In general, when a host posses the information necessary to allow
other hosts to communicate, it should provide that information
whenever possible.
