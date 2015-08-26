From: Stas Sergeev <stsp@list.ru>
Subject: Re: [v2] net: phy: fixed: propagate fixed link values to struct
Date: Wed, 26 Aug 2015 18:51:21 +0300
Message-ID: <55DDE079.7070401@list.ru>
References: <1440601127-7663-1-git-send-email-madalin.bucur@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Igal.Liberman@freescale.com
To: madalin.bucur@freescale.com, f.fainelli@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1440601127-7663-1-git-send-email-madalin.bucur@freescale.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

26.08.2015 17:58, Madalin Bucur =D0=BF=D0=B8=D1=88=D0=B5=D1=82:
> The fixed link values parsed from the device tree are stored in
> the struct fixed_phy member status. The struct phy_device members
> speed, duplex were not updated.

ACK, but IMHO it will make more sense if you include that
into your upcoming patch set rather than sending separately,
as otherwise there is simply no in-kernel users of that new
functionality (all the current users likely do not access
these fields as early as you want to, so they don't care).
In any case, the patch looks good to me and the policy is
up to others.
