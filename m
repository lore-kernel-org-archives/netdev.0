From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH net-next 12/14] r8152: replace netif_rx with
 netif_receive_skb
Date: Wed, 19 Feb 2014 00:28:50 +0100
Message-ID: <20140218232850.GB13394@electric-eye.fr.zoreil.com>
References: <1392731351-25502-1-git-send-email-hayeswang@realtek.com>
 <1392731351-25502-13-git-send-email-hayeswang@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, nic_swsd@realtek.com,
	linux-kernel@vger.kernel.org, linux-usb@vger.kernel.org
To: Hayes Wang <hayeswang@realtek.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1392731351-25502-13-git-send-email-hayeswang@realtek.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hayes Wang <hayeswang@realtek.com> :
> Replace netif_rx with netif_receive_skb to avoid disabling irq frequently
> for increasing the efficiency.

read_bulk_callback is issued in irq context. It could thus use plain
spin_lock / spin_unlock instead of the irq disabling version.

-- 
Ueimor
