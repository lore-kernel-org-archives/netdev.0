From: Wang YanQing <udknight@gmail.com>
Subject: Re: [PATCH]realtek:r8169: Bugfix or workaround for missing extended
 GigaMAC registers settings
Date: Fri, 30 Nov 2012 17:04:29 +0800
Message-ID: <20121130090429.GA14439@udknight>
References: <20121130050619.GA12862@udknight>
 <20121130063500.GA9436@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nic_swsd@realtek.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Hayes Wang <hayeswang@realtek.com>
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20121130063500.GA9436@electric-eye.fr.zoreil.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Nov 30, 2012 at 07:35:00AM +0100, Francois Romieu wrote:
> Which kernel version is it ?
I have done the test and debug  with mainline 
e23739b4ade80a3a7f87198f008f6c44a7cbc9fd, v3.7-rc7-51-ge23739b

> I'd rather see the GigaMAC registers written through a call to
> rtl_rar_set when the mac address is read in rtl_init_one instead
> of duplicating most of rtl_rar_set in a quite different place.

I have the same feeling with you, I will resend the patch follow
your opinion if everything pass test and work.

Thanks
