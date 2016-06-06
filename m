From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [net-next PATCH 3/3] net sched actions: aggregate dumping of
 actions timeinfo
Date: Sun, 5 Jun 2016 22:39:14 -0700
Message-ID: <CAM_iQpWdfP91GUkhJW70ii15uwr1vEPEpF2b8hkfSPA02NVreg@mail.gmail.com>
References: <1465136801-19644-1-git-send-email-jhs@emojatatu.com> <1465136801-19644-4-git-send-email-jhs@emojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Daniel Borkmann <daniel@iogearbox.net>
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f196.google.com ([209.85.161.196]:36195 "EHLO
	mail-yw0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750789AbcFFFje (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Jun 2016 01:39:34 -0400
Received: by mail-yw0-f196.google.com with SMTP id l126so17836540ywe.3
        for <netdev@vger.kernel.org>; Sun, 05 Jun 2016 22:39:34 -0700 (PDT)
In-Reply-To: <1465136801-19644-4-git-send-email-jhs@emojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Jun 5, 2016 at 7:26 AM, Jamal Hadi Salim <jhs@mojatatu.com> wrote:
> diff --git a/include/net/act_api.h b/include/net/act_api.h
> index 8389c00..5453f52 100644
> --- a/include/net/act_api.h
> +++ b/include/net/act_api.h
> @@ -80,6 +80,14 @@ static inline void tcf_lastuse_update(struct tcf_t *tm)
>                 tm->firstuse = now;
>  }
>
> +static inline void tcf_tm_dump(struct tcf_t *dtm, struct tcf_t *stm)

Nit: const struct tcf_t *stm. ;)

The rest looks good.

Thanks.
