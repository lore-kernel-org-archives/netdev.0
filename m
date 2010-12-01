From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH] net/r8169: Remove the firmware of RTL8111D
Date: Wed, 1 Dec 2010 17:05:52 +0000
Message-ID: <20101201170552.GK8695@decadent.org.uk>
References: <1291180966-3124-1-git-send-email-hayeswang@realtek.com> <20101201080732.GA3234@electric-eye.fr.zoreil.com> <201012011736.59625.s.L-H@gmx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Francois Romieu <romieu@fr.zoreil.com>,
	Hayes Wang <hayeswang@realtek.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Stefan Lippers-Hollmann <s.L-H@gmx.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <201012011736.59625.s.L-H@gmx.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Dec 01, 2010 at 05:36:55PM +0100, Stefan Lippers-Hollmann wrote:
> Hi
> 
> On Wednesday 01 December 2010, Francois Romieu wrote:
> > Hayes Wang <hayeswang@realtek.com> :
> > > Remove the firmware of RTL8111D from the kernel.
> > > The binary file of firmware would be moved to linux-firmware repository.
> > 
> > The driver can not simply go along when request_firmware fails. Though Ben's
> > code did not take care of it, the driver should imho propagate some return
> > code. Ben ?
> [...]
> 
> At least for RTL8111D-1 (rtl8168d_1_hw_phy_config(), phy_reg_init_2[])
> a missing firmware update doesn't seem to be fatal
> 	http://bugs.debian.org/561309#45
[...]

Yes.  Though it does clearly affect operation with some combinations of
cable and link partner.  There was a recent bug report on this, though
I can't find it now.

Ben.

-- 
Ben Hutchings
We get into the habit of living before acquiring the habit of thinking.
                                                              - Albert Camus
