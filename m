From: Kalle Valo <kvalo@codeaurora.org>
Subject: Re: wil6210: increase cmd buffer size to avoid sscanf buffer overflow
Date: Tue,  3 Mar 2015 13:48:34 +0000 (UTC)
Message-ID: <20150303134834.AA167140CD2@smtp.codeaurora.org>
References: <1425232113-5010-1-git-send-email-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Vladimir Kondratiev <qca_vkondrat@qca.qualcomm.com>,
	linux-wireless@vger.kernel.org, wil6210@qca.qualcomm.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Colin Ian King <colin.king@canonical.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1425232113-5010-1-git-send-email-colin.king@canonical.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


> From: Colin Ian King <colin.king@canonical.com>
> 
> cppcheck detected a buffer overflow:
> 
> [drivers/net/wireless/ath/wil6210/debugfs.c:634]: (error) Width 8
>   given in format string (no. 1) is larger than destination buffer
>   'cmd[8]', use %7s to prevent overflowing it.
> 
> For the current %8s sscanf we require cmd to be 9 chars long
> so increase it by 1 byte to prevent the sscan overflow (rather
> than reduce the %8s specifier to %7s as cppcheck recommends).
> 
> Signed-off-by: Colin Ian King <colin.king@canonical.com>
> Acked-by: Vladimir Kondratiev <qca_vkondrat@qca.qualcomm.com>

Thanks, applied to wireless-drivers-next.git.

Kalle Valo
