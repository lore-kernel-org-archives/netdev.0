From: David Miller <davem@davemloft.net>
Subject: Re: [Bugme-new] [Bug 7450] New: e1000: eth0: e1000_clean_tx_irq:
 Detected Tx Unit Hang
Date: Thu, 02 Nov 2006 23:13:05 -0800 (PST)
Message-ID: <20061102.231305.74560981.davem@davemloft.net>
References: <20061102112015.d4f5c60e.akpm@osdl.org>
	<454A67C0.6040201@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@osdl.org, jesse.brandeburg@intel.com, netdev@vger.kernel.org,
	pstaszewski@artcom.pl, bugme-daemon@bugzilla.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:5306
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1753177AbWKCHNY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 3 Nov 2006 02:13:24 -0500
To: auke-jan.h.kok@intel.com
In-Reply-To: <454A67C0.6040201@intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Auke Kok <auke-jan.h.kok@intel.com>
Date: Thu, 02 Nov 2006 13:48:48 -0800

> the hang is caused by a bad eeprom bit. A script that fixes it for
> 82573-series with eeproms that need this bit fixed is attached to
> the bugreport. It detects the proper chipset and patches if required
> (uses ethtool).

Those third party card makers, they always mess up the eeprom
making things hard to support. :-)

