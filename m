From: Kalle Valo <kvalo@codeaurora.org>
Subject: Re: [PATCH 1/1] net: wireless: intersil: fix improper return value
Date: Wed, 07 Dec 2016 14:00:31 +0200
Message-ID: <8760mwdk4g.fsf@kamboji.qca.qualcomm.com>
References: <1480760572-4444-1-git-send-email-bianpan2016@163.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Pan Bian <bianpan2016@163.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1480760572-4444-1-git-send-email-bianpan2016@163.com> (Pan
        Bian's message of "Sat, 3 Dec 2016 18:22:52 +0800")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Pan Bian <bianpan2016@163.com> writes:

> Function orinoco_ioctl_commit() returns 0 (indicates success) when the
> call to orinoco_lock() fails. Thus, the return value is inconsistent with
> the execution status. It may be better to return "-EBUSY" when the call 
> to orinoco_lock() fails.
>
> Bugzilla: https://bugzilla.kernel.org/show_bug.cgi?id=188671
>
> Signed-off-by: Pan Bian <bianpan2016@163.com>
> ---
>  drivers/net/wireless/intersil/orinoco/wext.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)

Please use prefix "orinoco:", more info:

https://wireless.wiki.kernel.org/en/developers/documentation/submittingpatches#subject_name

-- 
Kalle Valo
