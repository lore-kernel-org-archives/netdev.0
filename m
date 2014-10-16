From: Thomas Graf <tgraf@suug.ch>
Subject: Re: Netlink mmap tx security?
Date: Thu, 16 Oct 2014 08:07:53 +0100
Message-ID: <20141016070753.GA16738@casper.infradead.org>
References: <CALCETrWDSG2EhxBnM8Jm55Ov8PYQ_w3Wf88SKYOB1q1WgRpbEw@mail.gmail.com>
 <20141014.220111.179628329028952302.davem@davemloft.net>
 <CALCETrW1HFJ3QXMfV9Hv922eax0hbHJn5GmHPvtED8_JR5KOVg@mail.gmail.com>
 <20141014.220908.123550384430402000.davem@davemloft.net>
 <543F6998.5090000@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, luto@amacapital.net,
	torvalds@linux-foundation.org, kaber@trash.net,
	netdev@vger.kernel.org
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:49962 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751329AbaJPHHz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Oct 2014 03:07:55 -0400
Content-Disposition: inline
In-Reply-To: <543F6998.5090000@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/16/14 at 08:45am, Daniel Borkmann wrote:
> On 10/15/2014 04:09 AM, David Miller wrote:
> >That would work as well.
> >
> >There are pros and cons to all of these approaches.
> >
> >I was thinking that if we do the "TX mmap --> copy to kernel buffer"
> >approach, then if in the future we find a way to make it work
> >reliably, we can avoid the copy.  And frankly performance wise it's no
> >worse than what happens via normal sendmsg() calls.
> >
> >And all applications using NETLINK_RX_RING keep working and keep
> >getting the performance boost.
> 
> That would be better, yes. This would avoid having such a TPACKET_V*
> API chaos we have in packet sockets if this could be fixed for netlink
> eventually.

Only saw the second part of Dave's message now. I agree that this
is even a better option.
