From: Kalle Valo <kvalo@codeaurora.org>
Subject: Re: [PATCH] [net] Fix error handling in ezusb_probe()
Date: Mon, 21 Sep 2015 13:24:02 +0300
Message-ID: <87eghsqddp.fsf@kamboji.qca.qualcomm.com>
References: <4fb5a5fe.340c.14fe3857f23.Coremail.zy900702@163.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: RUC_Soft_Sec <zy900702@163.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4fb5a5fe.340c.14fe3857f23.Coremail.zy900702@163.com> (RUC Soft
	Sec's message of "Sat, 19 Sep 2015 10:53:41 +0800 (CST)")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

RUC_Soft_Sec <zy900702@163.com> writes:

> Current code assigns 0 to variable 'retval', which makes ezusb_probe()
> to return success even if alloc_orinocodev() fails.
>
> Fix it by checking the return value from alloc_orinocodev() and
> assigns '-ENOMEM' to variable 'retval' in the case of error.
>
>
> Signed-off-by: RUC_Soft_Sec <zy900702@163.com>

Please use your real name both in From header and in Signed-off-by line.
Also use "orinoco_usb:" as the prefix in the commit title.

> ---
>  orinoco_usb.c |    1 +
>  1 file changed, 1 insertion(+)

This is wrong, the patch should contain the full source path.


-- 
Kalle Valo
