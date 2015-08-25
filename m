From: Ondrej Zary <linux@rainbow-software.org>
Subject: Re: [RFC, RFT PATCH 1/2] dl2k: Add support for IP1000A-based cards
Date: Tue, 25 Aug 2015 23:26:13 +0200
Message-ID: <201508252326.13784.linux@rainbow-software.org>
References: <1440363988-12325-1-git-send-email-linux@rainbow-software.org> <20150825.140430.663421843230467362.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	romieu@fr.zoreil.com
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150825.140430.663421843230467362.davem@davemloft.net>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tuesday 25 August 2015 23:04:30 David Miller wrote:
> From: Ondrej Zary <linux@rainbow-software.org>
> Date: Sun, 23 Aug 2015 23:06:27 +0200
>
> > Add support for IP1000A chips to dl2k driver.
> > IP1000A chip looks like a TC9020 with integrated PHY.
> >
> > Tested with Asus NX1101.
>
> You're saying the PHY support is incomplete, so gigabit isn't even
> detected for these chips.
>
> So in a way this is a regression of sorts.
>
> Come back with these proposed changes once you have the PHY support
> situation sorted out.
>
> Thanks.

Actually, gigabit works with this patch. The "PHY magic" part contains 
mii_write(9, 0x0700) which makes gigabit work.

BTW. D-Link DGE-550T is on the way so I'll test that too.

-- 
Ondrej Zary
