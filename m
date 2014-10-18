From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH 1/2] staging: lustre: lnet: lnet: do not initialise 0
Date: Sat, 18 Oct 2014 21:04:43 +0400
Message-ID: <54429DAB.4060906@cogentembedded.com>
References: <20141018040330.GA23492@vasu-Inspiron-3542>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org
To: Balavasu <kp.balavasu@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f49.google.com ([209.85.215.49]:39321 "EHLO
	mail-la0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751394AbaJRRFC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 18 Oct 2014 13:05:02 -0400
Received: by mail-la0-f49.google.com with SMTP id q1so2109431lam.36
        for <netdev@vger.kernel.org>; Sat, 18 Oct 2014 10:05:00 -0700 (PDT)
In-Reply-To: <20141018040330.GA23492@vasu-Inspiron-3542>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 10/18/2014 8:03 AM, Balavasu wrote:

> This patch fixes the checkpatch.pl issue
> Error:do not initialise statics to 0 or NULL

> Signed-off-by: Balavasu <kp.balavasu@gmail.com>
> ---
>   drivers/staging/lustre/lnet/lnet/router.c | 10 +++++-----
>   1 file changed, 5 insertions(+), 5 deletions(-)

> diff --git a/drivers/staging/lustre/lnet/lnet/router.c b/drivers/staging/lustre/lnet/lnet/router.c
> index b5b8fb5..b6edf1f 100644
> --- a/drivers/staging/lustre/lnet/lnet/router.c
> +++ b/drivers/staging/lustre/lnet/lnet/router.c
[...]
> @@ -80,7 +80,7 @@ lnet_peer_buffer_credits(lnet_ni_t *ni)
>
>   #endif
>
> -static int check_routers_before_use = 0;
> +static int check_routers_before_use = {0};

    Eh? I thought {} is only for arrays/structures...

[...]

WBR, Sergei
