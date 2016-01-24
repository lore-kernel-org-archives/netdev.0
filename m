From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH] net: dsa: fix mv88e6xxx switches
Date: Sun, 24 Jan 2016 01:01:41 -0500
Message-ID: <87y4bfjz22.fsf@ketchup.mtl.sfl>
References: <E1aMvmm-0006G3-8T@rmk-PC.arm.linux.org.uk> <20160123181526.GD3880@lunn.ch> <20160123190622.GA10826@n2100.arm.linux.org.uk> <20160123193705.GE3880@lunn.ch> <20160123194856.GB10826@n2100.arm.linux.org.uk> <20160123201647.GH3880@lunn.ch> <20160123204416.GC10826@n2100.arm.linux.org.uk> <20160123221232.GJ3880@lunn.ch> <20160123222326.GK3880@lunn.ch> <20160123233116.GD10826@n2100.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org
To: Russell King - ARM Linux <linux@arm.linux.org.uk>,
	Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:37857 "EHLO
	mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750938AbcAXGBw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 24 Jan 2016 01:01:52 -0500
In-Reply-To: <20160123233116.GD10826@n2100.arm.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Russell,

Russell King - ARM Linux <linux@arm.linux.org.uk> writes:

> On Sat, Jan 23, 2016 at 11:23:26PM +0100, Andrew Lunn wrote:
>> On Sat, Jan 23, 2016 at 11:12:32PM +0100, Andrew Lunn wrote:
>> > Hi Russell
>> > 
>> > Never called.
>> > 
>> > So i guess we have a kernel configuration difference.
>> > 
>> > I don't have CONFIG_BRIDGE_VLAN_FILTERING.
>> 
>> Yep, confirmed. When i enable this option, and VLAN_8021Q which it
>> depends on, i then have a working bridge.
>
> It sounds like Vivien urgently needs to do some extra work to fix
> the patches that created all this broken-ness, or we need to ask
> davem to revert back to a known good working state.

Indeed hardware bridging currently relies on 802.1Q and VLAN filtering
enabled. I will work on this asap.

Thanks,
-v
