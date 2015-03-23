From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Net: ethernet: rocker: fixed a space coding style issue
Date: Mon, 23 Mar 2015 13:20:25 -0400 (EDT)
Message-ID: <20150323.132025.1558105817791850699.davem@davemloft.net>
References: <1426960960-31552-1-git-send-email-andreimaresu@gmail.com>
	<20150323131839.GB2038@nanopsycho.lan>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: andreimaresu@gmail.com, sfeldma@gmail.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56418 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752633AbbCWRU2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Mar 2015 13:20:28 -0400
In-Reply-To: <20150323131839.GB2038@nanopsycho.lan>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Mon, 23 Mar 2015 14:18:39 +0100

> Sat, Mar 21, 2015 at 07:02:40PM CET, andreimaresu@gmail.com wrote:
>>Fixed a space coding style issue found by checkpatch.pl in rocker.c
>>
>>Signed-off-by: Andrei Maresu <andreimaresu@gmail.com>
>>---
>> drivers/net/ethernet/rocker/rocker.c | 2 +-
>> 1 file changed, 1 insertion(+), 1 deletion(-)
>>
>>diff --git a/drivers/net/ethernet/rocker/rocker.c b/drivers/net/ethernet/rocker/rocker.c
>>index 9fb6948..d364b12 100644
>>--- a/drivers/net/ethernet/rocker/rocker.c
>>+++ b/drivers/net/ethernet/rocker/rocker.c
>>@@ -812,7 +812,7 @@ static void *rocker_desc_cookie_ptr_get(struct rocker_desc_info *desc_info)
>> static void rocker_desc_cookie_ptr_set(struct rocker_desc_info *desc_info,
>> 				       void *ptr)
>> {
>>-	desc_info->desc->cookie = (uintptr_t) ptr;
>>+	desc_info->desc->cookie = (uintptr_t)ptr;
> 
> Checkpatch does not mark this as an error, not even as a warning:
> "CHECK: No space is necessary after a cast". I personally like the
> notation with space better.

Me too, I'm not applying this.
