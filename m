From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 4/8] hamradio: baycom: fix old-style declaration
Date: Thu, 16 Jun 2016 22:06:54 -0700 (PDT)
Message-ID: <20160616.220654.973287495670086323.davem@davemloft.net>
References: <20160616135020.3154461-1-arnd@arndb.de>
	<20160616135245.3198419-1-arnd@arndb.de>
	<20160616135245.3198419-4-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, t.sailer@alumni.ethz.ch,
	linux-hams@vger.kernel.org, linux-kernel@vger.kernel.org
To: arnd@arndb.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160616135245.3198419-4-arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Arnd Bergmann <arnd@arndb.de>
Date: Thu, 16 Jun 2016 15:52:11 +0200

> Modern C standards expect the '__inline__' keyword to come before the return
> type in a declaration, and we get a warning for this with "make W=1":
> 
> drivers/net/hamradio/baycom_par.c:159:1: error: '__inline__' is not at beginning of declaration [-Werror=old-style-declaration]
> 
> For consistency with other drivers, I'm changing '__inline__' to 'inline'
> at the same time.
> 
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>

Applied.
