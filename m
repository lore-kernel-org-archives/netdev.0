From: "David S. Miller" <davem@redhat.com>
Subject: Re: [2.4 PATCH] bugfix: ARP respond on all devices
Date: Tue, 19 Aug 2003 09:14:14 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030819091414.512d80c4.davem@redhat.com>
References: <20030819145403.GA3407@alpha.home.local>
	<Pine.LNX.3.96.1030819114722.6826F-100000@gatekeeper.tmr.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: willy@w.ods.org, richard@aspectgroup.co.uk, alan@lxorguk.ukuu.org.uk,
   skraw@ithnet.com, carlosev@newipnet.com, lamont@scriptkiddie.org,
   bloemsaa@xs4all.nl, marcelo@conectiva.com.br, netdev@oss.sgi.com,
   linux-net@vger.kernel.org, layes@loran.com, torvalds@osdl.org,
   linux-kernel@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Bill Davidsen <davidsen@tmr.com>
In-Reply-To: <Pine.LNX.3.96.1030819114722.6826F-100000@gatekeeper.tmr.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 19 Aug 2003 11:53:29 -0400 (EDT)
Bill Davidsen <davidsen@tmr.com> wrote:

> I wonder if a change to add a flag preventing *any* packet from being sent
> on a NIC which doesn't have the proper source address would be politically
> acceptable.

This would disable things like MSG_DONTROUTE and many valid
uses of RAW sockets.
