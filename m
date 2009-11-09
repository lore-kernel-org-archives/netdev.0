From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] net/compat_ioctl: support SIOCWANDEV
Date: Sun, 08 Nov 2009 20:57:11 -0800 (PST)
Message-ID: <20091108.205711.153582422.davem@davemloft.net>
References: <20091106.204753.223665411.davem@davemloft.net>
	<200911082231.48060.arnd@arndb.de>
	<200911082239.24698.arnd@arndb.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: khc@pm.waw.pl, dwalker@fifo99.com, linux-kernel@vger.kernel.org,
	hch@lst.de, netdev@vger.kernel.org
To: arnd@arndb.de
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754278AbZKIE4r@vger.kernel.org>
In-Reply-To: <200911082239.24698.arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Arnd Bergmann <arnd@arndb.de>
Date: Sun, 8 Nov 2009 22:39:24 +0100

> This adds compat_ioctl support for SIOCWANDEV, which has
> always been missing.
> 
> The definition of struct compat_ifreq was missing an
> ifru_settings fields that is needed to support SIOCWANDEV,
> so add that and clean up the whitespace damage in the
> struct definition.
> 
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>

Applied, thanks.
