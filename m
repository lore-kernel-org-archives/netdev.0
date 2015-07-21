From: arno@natisbad.org (Arnaud Ebalard)
Subject: Re: [PATCH net v5 0/4] net: enable inband link state negotiation only when explicitly requested
Date: Tue, 21 Jul 2015 22:18:00 +0200
Message-ID: <87vbddmfif.fsf@natisbad.org>
References: <1437439798-12622-1-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	linux-kernel@vger.kernel.org, mxs@sbrk.org,
	devicetree@vger.kernel.org, thomas.petazzoni@free-electrons.com
To: Florian Fainelli <f.fainelli@gmail.com>, stsp@users.sourceforge.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi guys,

Florian Fainelli <f.fainelli@gmail.com> writes:

> Changes in v5:
>
> - removed an invalid use of the link_update callback in the SF2 driver
>   was appeared after merging "net: phy: fixed_phy: handle link-down case"
>
> - reworded the commit message for patch 2 to make it clear what it fixes and
>   why this is required
>
> Initial cover letter from Stas:
>
> Hello.
>
> Currently the link status auto-negotiation is enabled
> for any SGMII link with fixed-link DT binding.
> The regression was reported:
> https://lkml.org/lkml/2015/7/8/865
> Apparently not all HW that implements SGMII protocol, generates the
> inband status for the auto-negotiation to work.
> More details here:
> https://lkml.org/lkml/2015/7/10/206
>
> The following patches reverts to the old behavior by default,
> which is to not enable the auto-negotiation for fixed-link.
> The new DT property is added that allows to explicitly request
> the auto-negotiation.

FWIW, I tested this v5 series on mirabox (2 mvneta interfaces using
RGMII); both interfaces still work as expected, i.e. no regression
on my side.

a+
