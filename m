From: Michal Simek <michal.simek@xilinx.com>
Subject: Re: [PATCH] drivers: net: ethernet: xilinx: xilinx_emaclite: revert
 the original commit "1db3ddff1602edf2390b7667dcbaa0f71512e3ea"
Date: Wed, 5 Nov 2014 08:19:41 +0100
Message-ID: <a39951cc744047679d13b23e76c97347@BN1BFFO11FD022.protection.gbl>
References: <5458E605.6070801@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Chen Gang <gang.chen.5i5j@gmail.com>, <michal.simek@xilinx.com>,
	<soren.brinkmann@xilinx.com>, <davem@davemloft.net>,
	<sthokal@xilinx.com>, <manuel.schoelling@gmx.de>,
	<f.fainelli@gmail.com>, <paul.gortmaker@windriver.com>,
	<ebiederm@xmission.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <5458E605.6070801@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 11/04/2014 03:43 PM, Chen Gang wrote:
> Microblaze is a fpga soft core, it can be customized easily, which may
> cause many various hardware version strings.
> 
> So the original fix patch based on hard-coded compatible version strings
> is not a good idea (although it is correct for current issue). For it,
> there will be a new solving way soon (which based on the device tree).
> 
> The original issue is related with qemu, so can only change the hardware
> version string in qemu for it, then keep the original driver no touch (
> qemu is for virtualization which has much easier life than real world).
> 
> 
> Signed-off-by: Chen Gang <gang.chen.5i5j@gmail.com>
> ---
>  drivers/net/ethernet/xilinx/xilinx_emaclite.c | 1 -
>  1 file changed, 1 deletion(-)

Acked-by: Michal Simek <michal.simek@xilinx.com>

Thanks,
Michal
