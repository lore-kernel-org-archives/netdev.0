From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH net-next] qdisc: basic classifier - remove unnecessary
 initialization
Date: Sun, 29 Sep 2013 07:28:17 -0400
Message-ID: <52480ED1.4080704@mojatatu.com>
References: <20130926174216.447555bd@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f170.google.com ([209.85.223.170]:48745 "EHLO
	mail-ie0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751103Ab3I2L20 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 29 Sep 2013 07:28:26 -0400
Received: by mail-ie0-f170.google.com with SMTP id x13so7905252ief.1
        for <netdev@vger.kernel.org>; Sun, 29 Sep 2013 04:28:26 -0700 (PDT)
In-Reply-To: <20130926174216.447555bd@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 13-09-26 08:42 PM, Stephen Hemminger wrote:
> err is set once, then first code resets it.
>    err = tcf_exts_validate(...)
>
> Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>
>
>
> --- a/net/sched/cls_basic.c	2013-08-10 10:36:11.657498301 -0700
> +++ b/net/sched/cls_basic.c	2013-09-05 18:05:14.718200833 -0700
> @@ -137,7 +137,7 @@ static int basic_set_parms(struct net *n
>   			   struct nlattr **tb,
>   			   struct nlattr *est)
>   {
> -	int err = -EINVAL;
> +	int err;
>   	struct tcf_exts e;
>   	struct tcf_ematch_tree t;
>


Acked-by: Jamal Hadi Salim <hadi@mojatatu.com>


cheers,
jamal
