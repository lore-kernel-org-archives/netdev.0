From: Wang YanQing <udknight@gmail.com>
Subject: Re: [PATCH]realtek:r8169: Bugfix or workaround for missing extended
 GigaMAC registers settings
Date: Sat, 1 Dec 2012 09:50:49 +0800
Message-ID: <20121201015049.GA4209@udknight>
References: <20121130050619.GA12862@udknight>
 <20121130063500.GA9436@electric-eye.fr.zoreil.com>
 <20121130090429.GA14439@udknight>
 <20121130100002.GA6253@udknight>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: Francois Romieu <romieu@fr.zoreil.com>, nic_swsd@realtek.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Hayes Wang <hayeswang@realtek.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20121130100002.GA6253@udknight>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Nov 30, 2012 at 06:00:02PM +0800, Wang YanQing wrote:
> I found the mainline's r8169 works the same as realtek's driver,
> the first time don't work, but it works after reboot, the reason
> is the pci driver's shutdown don't call rtl_rar_set in 3.0 stable
> tree but the mainline does.
Sorry, I make a mistake here, the boths pci driver's shutdown call 
rtl_rar_set, but 3.0 stable tree don't include commit 
c28aa38567101bad4e020f4392df41d0bf6c165c(r8169 : MAC address change fix for the 8168e-vl)

Thanks
