From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] vmxnet3: fix checks for dma mapping errors
Date: Tue, 01 Dec 2015 15:19:45 -0500 (EST)
Message-ID: <20151201.151945.1312834964752711393.davem@davemloft.net>
References: <1448663370-6848-1-git-send-email-khoroshilov@ispras.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: skhare@vmware.com, pv-drivers@vmware.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, ldv-project@linuxtesting.org
To: khoroshilov@ispras.ru
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1448663370-6848-1-git-send-email-khoroshilov@ispras.ru>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Alexey Khoroshilov <khoroshilov@ispras.ru>
Date: Sat, 28 Nov 2015 01:29:30 +0300

> vmxnet3_drv does check dma_addr with dma_mapping_error()
> after mapping dma memory. The patch adds the checks and
> tries to handle failures.
> 
> Found by Linux Driver Verification project (linuxtesting.org).
> 
> Signed-off-by: Alexey Khoroshilov <khoroshilov@ispras.ru>

Applied with typo fixed, thanks.
