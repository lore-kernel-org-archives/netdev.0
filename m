From: Vlad Yasevich <vyasevich@gmail.com>
Subject: Re: [PATCH] sctp: fix sparse warning for sctp_init_cause_fixed
Date: Sat, 14 Jul 2012 14:01:25 -0400
Message-ID: <d271696b-1103-4335-a734-3cda1e260557@email.android.com>
References: <1342199797-11305-1-git-send-email-ioanorghici@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=UTF-8
Content-Transfer-Encoding: 8bit
To: Ioan Orghici <ioanorghici@gmail.com>, sri@us.ibm.com,
	davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f46.google.com ([209.85.216.46]:42357 "EHLO
	mail-qa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750915Ab2GNSBa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 Jul 2012 14:01:30 -0400
Received: by qadb17 with SMTP id b17so919961qad.19
        for <netdev@vger.kernel.org>; Sat, 14 Jul 2012 11:01:29 -0700 (PDT)
In-Reply-To: <1342199797-11305-1-git-send-email-ioanorghici@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ioan Orghici <ioanorghici@gmail.com> wrote:

>Fix the following sparse warning:
>	* symbol 'sctp_init_cause_fixed' was not declared. Should it be
>	  static?
>
>Signed-off-by: Ioan Orghici <ioanorghici@gmail.com>

Looks good.

Acked-by: Vlad Yasevich <vyasevich@gmail.com>


>---
> net/sctp/sm_make_chunk.c |    2 +-
> 1 files changed, 1 insertions(+), 1 deletions(-)
>
>diff --git a/net/sctp/sm_make_chunk.c b/net/sctp/sm_make_chunk.c
>index b6de71e..479a70e 100644
>--- a/net/sctp/sm_make_chunk.c
>+++ b/net/sctp/sm_make_chunk.c
>@@ -132,7 +132,7 @@ void  sctp_init_cause(struct sctp_chunk *chunk,
>__be16 cause_code,
>  * abort chunk.  Differs from sctp_init_cause in that it won't oops
>  * if there isn't enough space in the op error chunk
>  */
>-int sctp_init_cause_fixed(struct sctp_chunk *chunk, __be16 cause_code,
>+static int sctp_init_cause_fixed(struct sctp_chunk *chunk, __be16
>cause_code,
> 		      size_t paylen)
> {
> 	sctp_errhdr_t err;
>-- 
>1.7.6.3


-- 
Sent from my Android phone with SkitMail. Please excuse my brevity.
