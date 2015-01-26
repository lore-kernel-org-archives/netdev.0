From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] net: Linn Ethernet Packet Sniffer driver
Date: Mon, 26 Jan 2015 11:39:45 -0800
Message-ID: <1422301185.18650.4.camel@perches.com>
References: <1422007621-13567-1-git-send-email-stathis.voukelatos@linn.co.uk>
	 <1422135432.18650.2.camel@perches.com> <54C620CB.3010500@linn.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	devicetree@vger.kernel.org, abrestic@chromium.org
To: Stathis Voukelatos <stathis.voukelatos@linn.co.uk>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <54C620CB.3010500@linn.co.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2015-01-26 at 11:11 +0000, Stathis Voukelatos wrote:
> On 24/01/15 21:37, Joe Perches wrote:
> > On Fri, 2015-01-23 at 10:07 +0000, Stathis Voukelatos wrote:
> >> This patch adds support the Ethernet Packet Sniffer H/W module
> >> developed by Linn Products Ltd and found in the IMG Pistachio SoC.
> >> The module allows Ethernet packets to be parsed, matched against
> >> a user-defined pattern and timestamped. It sits between a 100M
> >> Ethernet MAC and PHY and is completely passive with respect to
> >> Ethernet frames.
> > []
> >>   include/linux/pkt_sniffer.h                        |  89 +++++
> > Why should this file be here?
> > Why not in the drivers/net/pkt-sniffer directory?
[]
> This header file is the public API for the driver.
> Should it not live under the 'include' directory?
> Several other drivers seem to follow that convention.

It depends on how public is public.

If it's _really_ public, it should be in uapi.
If it's kinda public, then _maybe_ it should be
in include/linux, but how likely is it another
driver will use it?
