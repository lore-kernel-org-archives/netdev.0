From: "David S. Miller" <davem@redhat.com>
Subject: Re: [2.4 PATCH] bugfix: ARP respond on all devices
Date: Tue, 19 Aug 2003 10:53:07 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030819105307.0b0a6491.davem@redhat.com>
References: <353568DCBAE06148B70767C1B1A93E625EAB5C@post.pc.aspectgroup.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: skraw@ithnet.com, willy@w.ods.org, alan@lxorguk.ukuu.org.uk,
   carlosev@newipnet.com, lamont@scriptkiddie.org, davidsen@tmr.com,
   bloemsaa@xs4all.nl, marcelo@conectiva.com.br, netdev@oss.sgi.com,
   linux-net@vger.kernel.org, layes@loran.com, torvalds@osdl.org,
   linux-kernel@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Richard Underwood <richard@aspectgroup.co.uk>
In-Reply-To: <353568DCBAE06148B70767C1B1A93E625EAB5C@post.pc.aspectgroup.co.uk>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 19 Aug 2003 18:56:18 +0100
Richard Underwood <richard@aspectgroup.co.uk> wrote:

> 	Which nicely sums up the bug, really.

Ok, then how would you propose to be able to send
packets out an interface _before_ we have addresses
assigned to it?

Linux allows that, and in fact it's a useful feature.

Consider MSG_DONTROUTE as well.

BTW, this ARP source address algorithm we use comes from
ipv6, it would be instructive to go and see why they do
things the way they do.
