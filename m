From: Matthew Garrett <mjg59@srcf.ucam.org>
Subject: Re: [PATCH] b44: power down PHY when interface down
Date: Sat, 30 Jun 2007 13:05:42 +0100
Message-ID: <20070630120541.GA21339@srcf.ucam.org>
References: <4354d3270706300447ladcda4by987b1f87963112f9@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: zambrano@broadcom.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, power@bughost.org
To: =?iso-8859-1?B?VPZy9ms=?= Edvin <edwintorok@gmail.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756994AbXF3MGS@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <4354d3270706300447ladcda4by987b1f87963112f9@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Jun 30, 2007 at 02:47:35PM +0300, T=F6r=F6k Edvin wrote:
> When the interface is down (or driver removed), the BroadCom 44xx car=
d=20
> remains
> powered on, and both its MAC and PHY is using up power.
> This patch makes the driver issue a MAC_CTRL_PHY_PDOWN when the inter=
face
> is halted, and does a partial chip reset turns off the activity LEDs =
too.

Do you still get link beat detection when the phy is powered down?

--=20
Matthew Garrett | mjg59@srcf.ucam.org
