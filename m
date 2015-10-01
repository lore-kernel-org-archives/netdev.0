From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH 01/12] net: fec: avoid timespec use
Date: Thu, 1 Oct 2015 21:08:08 +0200
Message-ID: <20151001190807.GA1872@localhost.localdomain>
References: <1443612402-3000775-1-git-send-email-arnd@arndb.de>
 <1443612402-3000775-2-git-send-email-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, y2038@lists.linaro.org,
	linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Fugang Duan <b38611@freescale.com>,
	Luwei Zhou <b45643@freescale.com>,
	Frank Li <Frank.Li@freescale.com>
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1443612402-3000775-2-git-send-email-arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Sep 30, 2015 at 01:26:31PM +0200, Arnd Bergmann wrote:
> The fec_ptp_enable_pps uses an open-coded implementation of ns_to_timespec,
> which will be removed eventually as it is not y2038-safe on 32-bit
> architectures. Two more instances of the same code in this file were
> already converted to use the safe ns_to_timespec64 in commit 6630514fcee
> ("ptp: fec: use helpers for converting ns to timespec"), this changes
> the last one as well.
> 
> The seconds portion here is actually unused and we could just remove the
> timespec variable, but using ns_to_timespec64 can still be better as the
> implementation can be hand-optimized in the future.
> 
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>

Acked-by: Richard Cochran <richardcochran@gmail.com>
