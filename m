From: Stas Sergeev <stsp@list.ru>
Subject: Re: [PATCH net v5 0/4] net: enable inband link state negotiation only
 when explicitly requested
Date: Tue, 21 Jul 2015 14:17:40 +0300
Message-ID: <55AE2A54.3010701@list.ru>
References: <1437439798-12622-1-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, linux-kernel@vger.kernel.org, mxs@sbrk.org,
	arno@natisbad.org, stsp@users.sourceforge.net,
	devicetree@vger.kernel.org, thomas.petazzoni@free-electrons.com
To: Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1437439798-12622-1-git-send-email-f.fainelli@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

21.07.2015 03:49, Florian Fainelli =D0=BF=D0=B8=D1=88=D0=B5=D1=82:
> Hi all,
>
> Changes in v5:
>
> - removed an invalid use of the link_update callback in the SF2 drive=
r
>    was appeared after merging "net: phy: fixed_phy: handle link-down =
case"
Thanks for bringing this forward!
=46or the future, perhaps it will make sense to also
teach phylib to never read link status (including speed)
when link is down. Will help to narrow more of such problems.
