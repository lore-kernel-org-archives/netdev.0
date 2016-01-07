From: Kalle Valo <kvalo@codeaurora.org>
Subject: Re: rt2x00pci: Disable memory-write-invalidate when the driver exits
Date: Thu,  7 Jan 2016 09:23:07 +0000 (UTC)
Message-ID: <20160107092307.76F55605BD@smtp.codeaurora.org>
References: <1451894138-3482-1-git-send-email-baijiaju1990@163.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: sgruszka@redhat.com, helmut.schaa@googlemail.com,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Jia-Ju Bai <baijiaju1990@163.com>
To: Jia-Ju Bai <baijiaju1990@163.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1451894138-3482-1-git-send-email-baijiaju1990@163.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


> The driver calls pci_set_mwi to enable memory-write-invalidate when it
> is initialized, but does not call pci_clear_mwi when it is removed. Many
> other drivers calls pci_clear_mwi when pci_set_mwi is called, such as
> r8169, 8139cp and e1000.
> 
> This patch adds pci_clear_mwi in error handling and removal procedure, 
> which can fix the problem.
> 
> Signed-off-by: Jia-Ju Bai <baijiaju1990@163.com>
> Acked-by: Helmut Schaa <helmut.schaa@googlemail.com>

Thanks, applied to wireless-drivers-next.git.

Kalle Valo
