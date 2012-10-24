From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH v3 net-next] r8169: enable ALDPS for power saving
Date: Wed, 24 Oct 2012 23:20:03 +0200
Message-ID: <20121024212003.GA11152@electric-eye.fr.zoreil.com>
References: <1350893153-18320-1-git-send-email-hayeswang@realtek.com> <1351059843-1464-1-git-send-email-hayeswang@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	jean@google.com
To: Hayes Wang <hayeswang@realtek.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1351059843-1464-1-git-send-email-hayeswang@realtek.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hayes Wang <hayeswang@realtek.com> :
> Enable ALDPS function to save power when link down. Note that the
> feature should be set after the other PHY settings. And the firmware
> is necessary. Don't enable it without loading the firmware.
> 
> None of the firmware-free chipsets support ALDPS. Neither do the
> RTL8168d/8111d.
> 
> For 8136 series, make sure the ALDPS is disabled before loading the
> firmware. For 8168 series, the ALDPS would be disabled automatically
> when loading firmware. You must not disable it directly.
> 
> Signed-off-by: Hayes Wang <hayeswang@realtek.com>

Acked-by: Francois Romieu <romieu@fr.zoreil.com>
