From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] bridge: mask forwarding of IEEE 802 local multicast
 groups
Date: Fri, 12 Aug 2011 15:45:45 -0700
Message-ID: <20110812154545.79d8313f@nehalam.ftrdhcpuser.net>
References: <CAF5U64C+WgQhfJL3zfVnvzE7p=G61humQCObHGUxAvY2-MGAFQ@mail.gmail.com>
	<CAF5U64CJTWDn8E9+XVLFsdaSbiu-4Rd9XmxZq7ReziRNZviO6Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Ed Swierk <eswierk@bigswitch.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:48843 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752388Ab1HLWpi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 12 Aug 2011 18:45:38 -0400
In-Reply-To: <CAF5U64CJTWDn8E9+XVLFsdaSbiu-4Rd9XmxZq7ReziRNZviO6Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 12 Aug 2011 15:37:54 -0700
Ed Swierk <eswierk@bigswitch.com> wrote:

> I'm using elaborate combinations of bridges, tunnels and vlans to make
> remote switches many hops away appear as though they're locally
> connected to a virtual machine. In this application the bridges are
> just used to forward traffic between a pair of interfaces. I need the
> bridge to behave as much like a dumb 2-port hub as possible,
> forwarding LLDP frames that 802.1d-compliant bridges normally drop.

If you turn off STP that is what it does right now. It forwards STP
and 802.1X frames. The patch was only related to turning on STP
and still expecting 802.1X frames to be forwarded (in violation of
the spec).
