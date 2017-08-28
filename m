From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2 1/4] tc: m_ife: allow ife type to zero
Date: Mon, 28 Aug 2017 12:34:13 -0700
Message-ID: <20170828123413.2283b2e1@xeon-e3>
References: <20170828190738.26829-1-aring@mojatatu.com>
        <20170828190738.26829-2-aring@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jhs@mojatatu.com, yotamg@mellanox.com, xiyou.wangcong@gmail.com,
        jiri@resnulli.us, netdev@vger.kernel.org
To: Alexander Aring <aring@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f175.google.com ([209.85.192.175]:36731 "EHLO
        mail-pf0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750735AbdH1TeP (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 28 Aug 2017 15:34:15 -0400
Received: by mail-pf0-f175.google.com with SMTP id z87so3907272pfi.3
        for <netdev@vger.kernel.org>; Mon, 28 Aug 2017 12:34:15 -0700 (PDT)
In-Reply-To: <20170828190738.26829-2-aring@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 28 Aug 2017 15:07:35 -0400
Alexander Aring <aring@mojatatu.com> wrote:

> This patch allows to set an ethertype for IFE which is zero. There is no
> kernel side validation which forbids a type to zero.
> 
> Signed-off-by: Alexander Aring <aring@mojatatu.com>
> ---
>  tc/m_ife.c | 4 +++-
>  1 file changed, 3 insertions(+), 1 deletion(-)
> 
> diff --git a/tc/m_ife.c b/tc/m_ife.c
> index e3521e62..e05e2276 100644
> --- a/tc/m_ife.c
> +++ b/tc/m_ife.c
> @@ -63,6 +63,7 @@ static int parse_ife(struct action_util *a, int *argc_p, char ***argv_p,
>  	char dbuf[ETH_ALEN];
>  	char sbuf[ETH_ALEN];
>  	__u16 ife_type = 0;
> +	int user_type = 0;

Please use bool if it is a flag value
