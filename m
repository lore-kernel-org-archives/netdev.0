From: Jesse Gross <jesse@nicira.com>
Subject: Re: TX VLAN acceleration on bridges broken in 2.6.37?
Date: Tue, 22 Feb 2011 17:32:32 -0800
Message-ID: <AANLkTimnFUxjzUBX_c0dAcJn-GFxWo2HCxbrCwPz+qET@mail.gmail.com>
References: <20110221232902.GA3440@x61s.reliablesolutions.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Jan Niehusmann <jan@gondor.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20110221232902.GA3440@x61s.reliablesolutions.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Feb 21, 2011 at 3:29 PM, Jan Niehusmann <jan@gondor.com> wrote:
> With the following configuration, sending vlan tagged traffic from a
> bridged interface doesn't work in 2.6.37.
> The same configuration does work with 2.6.36:
>
> - bridge br0 with physical interface eth0
> - eth0 being an e1000e device (don't know if that's important)
> - vlan interface br0.10
> - (on 2.6.37) tx vlan acceleration active on br0 (default)
>
> Networking on br0.10 doesn't work, and tcpdump on eth0 shows packets
> sent on br0.10 as untagged, instead of vlan 10 tagged.
>
> After turning vlan tx offloading off with 'ethtool -K br0 txvlan off',
> everything works as expected, again.
>
> The workaround is made permanent by reverting "bridge: Add support for
> TX vlan offload.", 361ff8a6cf90d62c0071b7e532e37369bfd3ae77, turning
> of the feature on bridges completely.

I tested this at one point and it worked but it sounds like something
broke after that.  It's probably fairly simple, so I'd rather just fix
the problem instead of reverting the commit.  I'm just coming back
from vacation and am trying to catch up but I'll try to look at it in
the next couple of days.
