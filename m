From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net/phy/bcm87xx: Add MODULE_LICENSE("GPL") to GPL
 driver
Date: Sat, 22 Sep 2012 15:34:26 -0400 (EDT)
Message-ID: <20120922.153426.978507671721485161.davem@davemloft.net>
References: <1348281858-24366-1-git-send-email-peterhuewe@gmx.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jacmet@sunsite.dk, david.daney@cavium.com,
	chohnstaedt@innominate.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, stable@vger.kernel.org
To: peterhuewe@gmx.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1348281858-24366-1-git-send-email-peterhuewe@gmx.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Peter Huewe <peterhuewe@gmx.de>
Date: Sat, 22 Sep 2012 04:44:18 +0200

> Currently the driver has no MODULE_LICENSE attribute in its source which
> results in a kernel taint if I load this:
> 
> root@(none):~# modprobe bcm87xx
> bcm87xx: module license 'unspecified' taints kernel.
> 
> Since the first lines of the source code clearly state:
>  * This file is subject to the terms and conditions of the GNU General
>  * Public License.  See the file "COPYING" in the main directory of this
>  * archive for more details.
> I think it's safe to add the MODULE_LICENSE("GPL") macro and thus remove
> the kernel taint.
> 
> Cc: stable@vger.kernel.org
> Signed-off-by: Peter Huewe <peterhuewe@gmx.de>

Good catch, applied, thanks.
