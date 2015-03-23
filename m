From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH] Net: ethernet: rocker: fixed a space coding style issue
Date: Mon, 23 Mar 2015 14:18:39 +0100
Message-ID: <20150323131839.GB2038@nanopsycho.lan>
References: <1426960960-31552-1-git-send-email-andreimaresu@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Scott Feldman <sfeldma@gmail.com>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Andrei Maresu <andreimaresu@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1426960960-31552-1-git-send-email-andreimaresu@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Sat, Mar 21, 2015 at 07:02:40PM CET, andreimaresu@gmail.com wrote:
>Fixed a space coding style issue found by checkpatch.pl in rocker.c
>
>Signed-off-by: Andrei Maresu <andreimaresu@gmail.com>
>---
> drivers/net/ethernet/rocker/rocker.c | 2 +-
> 1 file changed, 1 insertion(+), 1 deletion(-)
>
>diff --git a/drivers/net/ethernet/rocker/rocker.c b/drivers/net/ethernet/rocker/rocker.c
>index 9fb6948..d364b12 100644
>--- a/drivers/net/ethernet/rocker/rocker.c
>+++ b/drivers/net/ethernet/rocker/rocker.c
>@@ -812,7 +812,7 @@ static void *rocker_desc_cookie_ptr_get(struct rocker_desc_info *desc_info)
> static void rocker_desc_cookie_ptr_set(struct rocker_desc_info *desc_info,
> 				       void *ptr)
> {
>-	desc_info->desc->cookie = (uintptr_t) ptr;
>+	desc_info->desc->cookie = (uintptr_t)ptr;

Checkpatch does not mark this as an error, not even as a warning:
"CHECK: No space is necessary after a cast". I personally like the
notation with space better.


> }
> 
> static struct rocker_desc_info *
>-- 
>1.9.1
>
>--
>To unsubscribe from this list: send the line "unsubscribe netdev" in
>the body of a message to majordomo@vger.kernel.org
>More majordomo info at  http://vger.kernel.org/majordomo-info.html
