From: Dennis Chen <kernel.org.gnu@gmail.com>
Subject: Re: [Patch iproute2] skbedit: print action too
Date: Thu, 29 Jan 2015 11:49:23 +0800
Message-ID: <CA+U0gViQrppOQXsKwDHWOF5oWs61j6Hbck5o2LnMXMectm64xw@mail.gmail.com>
References: <1422485562-15572-1-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Stephen Hemminger <stephen@networkplumber.org>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:50319 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755704AbbA2Dtn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Jan 2015 22:49:43 -0500
Received: by mail-pa0-f52.google.com with SMTP id kx10so33515416pab.11
        for <netdev@vger.kernel.org>; Wed, 28 Jan 2015 19:49:43 -0800 (PST)
In-Reply-To: <1422485562-15572-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 29, 2015 at 6:52 AM, Cong Wang <xiyou.wangcong@gmail.com> wrote:
> Cc: Jamal Hadi Salim <jhs@mojatatu.com>
> Cc: Stephen Hemminger <stephen@networkplumber.org>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
> ---
>  tc/m_skbedit.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/tc/m_skbedit.c b/tc/m_skbedit.c
> index 36323a9..c5deee0 100644
> --- a/tc/m_skbedit.c
> +++ b/tc/m_skbedit.c
> @@ -193,7 +193,7 @@ static int print_skbedit(struct action_util *au, FILE *f, struct rtattr *arg)
>                 fprintf(f, " mark %d", *mark);
>         }
>
> -       fprintf(f, "\n\t index %d ref %d bind %d", p->index, p->refcnt, p->bindcnt);
> +       fprintf(f, " %s\n\t index %d ref %d bind %d", action_n2a(p->action, b1, sizeof (b1)), p->index, p->refcnt, p->bindcnt);
>
>         if (show_stats) {
>                 if (tb[TCA_SKBEDIT_TM]) {
> --
> 1.8.3.1
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

Hello cong, seems no big benifit I can see for the patch...

-- 
Den
