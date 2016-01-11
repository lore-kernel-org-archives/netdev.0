From: Stanislaw Gruszka <sgruszka@redhat.com>
Subject: Re: [PATCH] iwl4965: Fix a memory leak in error handling code of
 __il4965_up
Date: Mon, 11 Jan 2016 13:13:39 +0100
Message-ID: <20160111121339.GE25015@redhat.com>
References: <1452169059-20617-1-git-send-email-baijiaju1990@163.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kvalo@codeaurora.org, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Jia-Ju Bai <baijiaju1990@163.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1452169059-20617-1-git-send-email-baijiaju1990@163.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jan 07, 2016 at 08:17:39PM +0800, Jia-Ju Bai wrote:
> When il4965_hw_nic_init in __il4965_up fails, the memory allocated by 
> iwl4965_sta_alloc_lq in iwl4965_alloc_bcast_station is not freed.
> 
> This patches adds il_dealloc_bcast_stations in the error handling code of 
> __il4965_up to fix this problem.
> 
> This patch has been tested in real device, and it actually fixes the bug.
> 
> Signed-off-by: Jia-Ju Bai <baijiaju1990@163.com>

Acked-by: Stanislaw Gruszka <sgruszka@redhat.com>
