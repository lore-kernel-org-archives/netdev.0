From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ethtool: Extend ethtool plugin module eeprom API to
 phylib
Date: Tue, 06 Jan 2015 17:17:02 -0500 (EST)
Message-ID: <20150106.171702.634373983545087688.davem@davemloft.net>
References: <1420248476-110859-1-git-send-email-eswierk@skyportsystems.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, f.fainelli@gmail.com,
	linux-kernel@vger.kernel.org
To: eswierk@skyportsystems.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1420248476-110859-1-git-send-email-eswierk@skyportsystems.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ed Swierk <eswierk@skyportsystems.com>
Date: Fri,  2 Jan 2015 17:27:56 -0800

> This patch extends the ethtool plugin module eeprom API to support cards
> whose phy support is delegated to a separate driver.
> 
> The handlers for ETHTOOL_GMODULEINFO and ETHTOOL_GMODULEEEPROM call the
> module_info and module_eeprom functions if the phy driver provides them;
> otherwise the handlers call the equivalent ethtool_ops functions provided
> by network drivers with built-in phy support.
> 
> Signed-off-by: Ed Swierk <eswierk@skyportsystems.com>

Applied to net-next, thanks.
