From: Richard Underwood <richard@aspectgroup.co.uk>
Subject: RE: [2.4 PATCH] bugfix: ARP respond on all devices
Date: Tue, 19 Aug 2003 19:05:13 +0100
Sender: linux-net-owner@vger.kernel.org
Message-ID: <353568DCBAE06148B70767C1B1A93E625EAB5D@post.pc.aspectgroup.co.uk>
Mime-Version: 1.0
Content-Type: text/plain
Cc: willy@w.ods.org, alan@lxorguk.ukuu.org.uk, carlosev@newipnet.com,
	lamont@scriptkiddie.org, davidsen@tmr.com, bloemsaa@xs4all.nl,
	marcelo@conectiva.com.br, netdev@oss.sgi.com,
	linux-net@vger.kernel.org, layes@loran.com, torvalds@osdl.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-net-owner@vger.kernel.org>
To: "'David S. Miller'" <davem@redhat.com>,
	Stephan von Krawczynski <skraw@ithnet.com>
List-Id: netdev.vger.kernel.org

David S. Miller wrote:
> 
> In the ARP request we are using the source address in the packet we
> are building for output.
> 
	Well, you shouldn't be! The ARP request represents all FUTURE
packets being sent out that interface, not just the one single packet that
happened to kick of this ARP request.

> If ARP doesn't work using that source address, we can only assume IP
> communication is not possible either.
> 
	That's clearly not a valid assumption. For a start it precludes IP
routeing, but I've also demonstrated it not to be the case with a simple
multi-homed server.

	Thanks,

		Richard
