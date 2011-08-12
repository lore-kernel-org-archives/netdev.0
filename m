From: Ed Swierk <eswierk@bigswitch.com>
Subject: Re: [PATCH] bridge: mask forwarding of IEEE 802 local multicast groups
Date: Fri, 12 Aug 2011 15:37:54 -0700
Message-ID: <CAF5U64CJTWDn8E9+XVLFsdaSbiu-4Rd9XmxZq7ReziRNZviO6Q@mail.gmail.com>
References: <CAF5U64C+WgQhfJL3zfVnvzE7p=G61humQCObHGUxAvY2-MGAFQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:62762 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752388Ab1HLWif (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Aug 2011 18:38:35 -0400
Received: by wwf5 with SMTP id 5so3304135wwf.1
        for <netdev@vger.kernel.org>; Fri, 12 Aug 2011 15:38:34 -0700 (PDT)
In-Reply-To: <CAF5U64C+WgQhfJL3zfVnvzE7p=G61humQCObHGUxAvY2-MGAFQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger wrote:
> No.
> Don't like adding yet another hack user visible API which will have
> to be maintained for too long. But on the other hand I don't have
> a better solution at my finger tips. If better idea doesn't come
> along, then we can go with yours.

+1 for applying Nick Carter's patch adding a group_fwd_mask setting to
the bridge driver
(http://www.spinics.net/lists/netdev/msg169607.html).

I'm using elaborate combinations of bridges, tunnels and vlans to make
remote switches many hops away appear as though they're locally
connected to a virtual machine. In this application the bridges are
just used to forward traffic between a pair of interfaces. I need the
bridge to behave as much like a dumb 2-port hub as possible,
forwarding LLDP frames that 802.1d-compliant bridges normally drop.

I solemnly swear I will not pester the netdev list when I melt down my
LAN by inadvertently forwarding STP frames.

--Ed
