From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH net-next] r8169: Remove rtl_ocpdr_cond
Date: Thu, 12 Jul 2012 00:00:45 +0200
Message-ID: <20120711220045.GA8913@electric-eye.fr.zoreil.com>
References: <1342009916-1519-1-git-send-email-hayeswang@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Hayes Wang <hayeswang@realtek.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1342009916-1519-1-git-send-email-hayeswang@realtek.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hayes Wang <hayeswang@realtek.com> :
> No waiting is needed for mac_ocp_{write / read}. And the bit 31 of
> OCPDR would not change, so rtl_udelay_loop_wait_high always return
> false. That is, the r8168_mac_ocp_read always retuen ~0.

(testing with davem's 48ee3569f31d91084dc694fef5517eb782428083)

It seemed right at first sight but testing without firmware produces
unexpected results. While it is not exactly fast if I ask it to emit
packets with ping -qf, it turns really slow when I use the -l preload
option: at most a few hundreds pps.

An old pcie 8168b in the same computer behaves correctly with the same
kernel.

I'll try again tomorrow evening.

-- 
Ueimor
