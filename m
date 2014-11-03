From: Kalle Valo <kvalo@qca.qualcomm.com>
Subject: Re: [PATCH] ath6kl: remove incorrect reset_resume handler
Date: Tue, 4 Nov 2014 01:02:58 +0200
Message-ID: <87h9yf7uql.fsf@kamboji.qca.qualcomm.com>
References: <1414180972-16413-1-git-send-email-khoroshilov@ispras.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: "John W. Linville" <linville@tuxdriver.com>,
	<linux-wireless@vger.kernel.org>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, <ldv-project@linuxtesting.org>
To: Alexey Khoroshilov <khoroshilov@ispras.ru>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1414180972-16413-1-git-send-email-khoroshilov@ispras.ru> (Alexey
	Khoroshilov's message of "Sat, 25 Oct 2014 00:02:52 +0400")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Alexey Khoroshilov <khoroshilov@ispras.ru> writes:

> Existing implementation of reset_resume handler just calls
> ath6kl_usb_remove() that deallocates all resources.
> It can lead to double free, etc. on disconnect.
>
> The patch removes reset_resume handler,
> so usb core could conservatively reset the driver.
>
> Found by Linux Driver Verification project (linuxtesting.org).
>
> Signed-off-by: Alexey Khoroshilov <khoroshilov@ispras.ru>

Thanks, applied.

-- 
Kalle Valo
