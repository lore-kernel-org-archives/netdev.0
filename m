From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] r8169: set coherent DMA mask as well as streaming
 DMA mask
Date: Sat, 15 Oct 2016 17:29:49 -0400 (EDT)
Message-ID: <20161015.172949.326250924585943753.davem@davemloft.net>
References: <1476452433-20518-1-git-send-email-ard.biesheuvel@linaro.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: romieu@fr.zoreil.com, nic_swsd@realtek.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: ard.biesheuvel@linaro.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1476452433-20518-1-git-send-email-ard.biesheuvel@linaro.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Date: Fri, 14 Oct 2016 14:40:33 +0100

> PCI devices that are 64-bit DMA capable should set the coherent
> DMA mask as well as the streaming DMA mask. On some architectures,
> these are managed separately, and so the coherent DMA mask will be
> left at its default value of 32 if it is not set explicitly. This
> results in errors such as
> 
>      r8169 Gigabit Ethernet driver 2.3LK-NAPI loaded
>      hwdev DMA mask = 0x00000000ffffffff, dev_addr = 0x00000080fbfff000
>      swiotlb: coherent allocation failed for device 0000:02:00.0 size=4096
>      CPU: 0 PID: 1062 Comm: systemd-udevd Not tainted 4.8.0+ #35
>      Hardware name: AMD Seattle/Seattle, BIOS 10:53:24 Oct 13 2016
> 
> on systems without memory that is 32-bit addressable by PCI devices.
> 
> Signed-off-by: Ard Biesheuvel <ard.biesheuvel@linaro.org>

Applied.
