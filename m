From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: dsa: mv88e6xxx: split phy page accessors
Date: Tue, 23 Jun 2015 06:18:25 -0700 (PDT)
Message-ID: <20150623.061825.2036705332261161582.davem@davemloft.net>
References: <1434724330-3442-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andrew@lunn.ch, linux@roeck-us.net,
	linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com
To: vivien.didelot@savoirfairelinux.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33348 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932500AbbFWNGg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Jun 2015 09:06:36 -0400
In-Reply-To: <1434724330-3442-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Date: Fri, 19 Jun 2015 10:32:10 -0400

> Split mv88e6xxx_phy_page_read and mv88e6xxx_phy_page_write into two
> functions each, one to acquire the smi_mutex and one to call the actual
> read/write functions.
> 
> This will be useful to access registers such as Fiber/SERDES Control,
> from setup code with SMI lock held.
> 
> Also rename their "error" labels to "clear", since it is not only an
> error path.
> 
> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>

Please resubmit this alongside a patch that actually uses the new
facility.
