From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH resubmit] ax88179_178a: ASIX AX88179_178A USB 3.0/2.0
 to gigabit ethernet adapter driver
Date: Sun, 03 Mar 2013 01:44:14 -0500 (EST)
Message-ID: <20130303.014414.674265878687150706.davem@davemloft.net>
References: <1362220871-2395-1-git-send-email-freddy@asix.com.tw>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-usb@vger.kernel.org,
	linux-kernel@vger.kernel.org, louis@asix.com.tw
To: freddy@asix.com.tw
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1362220871-2395-1-git-send-email-freddy@asix.com.tw>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Freddy Xin <freddy@asix.com.tw>
Date: Sat,  2 Mar 2013 18:41:11 +0800

> From: Freddy Xin <freddy@asix.com.tw>
> 
> This is a resubmission.
> Added kfree() in ax88179_get_eeprom to prevent memory leakage.
> Modified "__le16 rxctl" to "u16 rxctl" in "struct ax88179_data" and removed pointless casts.
> Removed asix_init and asix_exit functions and added "module_usb_driver(ax88179_178a_driver)".
> Fixed endianness issue on big endian systems and verified this driver on iBook G4.
> Removed steps that change net->features in ax88179_set_features function.
> Added "const" to ethtool_ops structure and fixed the coding style of AX88179_BULKIN_SIZE array.
> Fixed the issue that the default MTU is not 1500.
> Added ax88179_change_mtu function and enabled the hardware jumbo frame function to support an
> MTU higher than 1500.
> Fixed indentation and empty line coding style errors.
> The _nopm version usb functions were added to access register in suspend and resume functions.
> Serveral variables allocted dynamically were removed and replaced by stack variables.
> ax88179_get_eeprom were modified from asix_get_eeprom in asix_common.
> 
> This patch adds a driver for ASIX's AX88179 family of USB 3.0/2.0
> to gigabit ethernet adapters. It's based on the AX88xxx driver but
> the usb commands used to access registers for AX88179 are completely different.
> This driver had been verified on x86 system with AX88179/AX88178A and
> Sitcomm LN-032 USB dongles.
> 
> Signed-off-by: Freddy Xin <freddy@asix.com.tw>

Applied.
