From: Chris Metcalf <cmetcalf@ezchip.com>
Subject: Re: [PATCH net-next V3 19/23] ptp: tilegx: convert to the 64 bit
 get/set time methods.
Date: Sun, 29 Mar 2015 17:32:46 -0400
Message-ID: <55186F7E.2030100@ezchip.com>
References: <cover.1427662906.git.richardcochran@gmail.com> <1f1b045d69be2bf9f73e0883877fb2cb710b7084.1427662907.git.richardcochran@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <linux-kernel@vger.kernel.org>, Amir Vadai <amirv@mellanox.com>,
	Ariel Elior <ariel.elior@qlogic.com>,
	Arnd Bergmann <arnd@linaro.org>,
	Baolin Wang <baolin.wang@linaro.org>,
	Ben Hutchings <ben@decadent.org.uk>,
	Bruce Allan <bruce.w.allan@intel.com>,
	Carolyn Wyborny <carolyn.wyborny@intel.com>,
	David Miller <davem@davemloft.net>,
	Frank Li <Frank.Li@freescale.com>,
	Giuseppe Cavallaro <peppe.cavallaro@st.com>,
	Jacob Keller <jacob.e.keller@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	John Stultz <john.stultz@linaro.org>,
	Luwei Zhou <b45643@freescale.com>,
	Matthew Vick <matthew.vick@intel.com>,
	Michael Chan <mchan@broadcom.com>,
	Prashant Sreedharan <prashant@broadcom.com>,
	Rayagond K <rayagond@vayavyalabs.com>,
	Shradha Shah <sshah@solarflare.com>,
	Solarflare linux maintainers <linux-net-drivers@solarflare.com>,
	Sonic Zhang <sonic.zhang@analog.com>,
	=?window
To: Richard Cochran <richardcochran@gmail.com>,
	<netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-db3on0063.outbound.protection.outlook.com ([157.55.234.63]:61312
	"EHLO emea01-db3-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752601AbbC2VdF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 29 Mar 2015 17:33:05 -0400
In-Reply-To: <1f1b045d69be2bf9f73e0883877fb2cb710b7084.1427662907.git.richardcochran@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 3/29/2015 5:12 PM, Richard Cochran wrote:
> This driver is 64 bit only, and so this driver and device are ready
> for 2038.  This patch changes the driver to the new PHC and also
> carries the timespec64 parameter on out to the gxio_mpipe_get-
> set_timestamp functions, making explicit the fact that the tv_sec
> field is 64 bits wide.
>
> Not even compile tested.
>
> Signed-off-by: Richard Cochran<richardcochran@gmail.com>
> ---
>   arch/tile/gxio/mpipe.c             |    4 ++--
>   arch/tile/include/gxio/mpipe.h     |    4 ++--
>   drivers/net/ethernet/tile/tilegx.c |    9 +++++----
>   3 files changed, 9 insertions(+), 8 deletions(-)

Acked-by: Chris Metcalf <cmetcalf@ezchip.com>

-- 
Chris Metcalf, EZChip Semiconductor
http://www.ezchip.com
