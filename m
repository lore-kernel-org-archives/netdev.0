From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH] lib: fix spelling mistake: "actualy" -> "actually"
Date: Sun, 26 Feb 2017 15:44:36 +0100
Message-ID: <20170226144436.GA2071@nanopsycho.orion>
References: <20170226121012.11766-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jiri Pirko <jiri@mellanox.com>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Colin King <colin.king@canonical.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170226121012.11766-1-colin.king@canonical.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Sun, Feb 26, 2017 at 01:10:12PM CET, colin.king@canonical.com wrote:
>From: Colin Ian King <colin.king@canonical.com>
>
>trivial fix to spelling mistake in pr_err message
>
>Signed-off-by: Colin Ian King <colin.king@canonical.com>

Acked-by: Jiri Pirko <jiri@mellanox.com>


>---
> lib/test_parman.c | 2 +-
> 1 file changed, 1 insertion(+), 1 deletion(-)
>
>diff --git a/lib/test_parman.c b/lib/test_parman.c
>index fe9f3a7..35e3224 100644
>--- a/lib/test_parman.c
>+++ b/lib/test_parman.c
>@@ -334,7 +334,7 @@ static int test_parman_check_array(struct test_parman *test_parman,
> 		last_priority = item->prio->priority;
> 
> 		if (item->parman_item.index != i) {
>-			pr_err("Item has different index in compare to where it actualy is (%lu != %d)\n",
>+			pr_err("Item has different index in compare to where it actually is (%lu != %d)\n",
> 			       item->parman_item.index, i);
> 			return -EINVAL;
> 		}
>-- 
>2.10.2
>
