From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH 08/10] ss: symmetrical subhandler output extension example
Date: Mon, 10 Aug 2015 15:19:06 +0300
Message-ID: <55C896BA.8040408@cogentembedded.com>
References: <1439162006-11421-1-git-send-email-matthias.tafelmeier@gmx.net>
 <1439162006-11421-9-git-send-email-matthias.tafelmeier@gmx.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: hagen@jauu.net, shemminger@osdl.org, fw@strlen.de,
	edumazet@google.com, daniel@iogearbox.net
To: Matthias Tafelmeier <matthias.tafelmeier@gmx.net>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f181.google.com ([209.85.217.181]:35269 "EHLO
	mail-lb0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750966AbbHJMTI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Aug 2015 08:19:08 -0400
Received: by lbbpo9 with SMTP id po9so94085498lbb.2
        for <netdev@vger.kernel.org>; Mon, 10 Aug 2015 05:19:07 -0700 (PDT)
In-Reply-To: <1439162006-11421-9-git-send-email-matthias.tafelmeier@gmx.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 8/10/2015 2:13 AM, Matthias Tafelmeier wrote:

> This small sized patch shall convey the locations which have to be
> changed for a symmetrical output extension. Symmetrical means in this
> context all existing semantically related handlers in the diverse
> formatters (for hr and json up to now).

> Signed-off-by: Matthias Tafelmeier <matthias.tafelmeier@gmx.net>
> Suggested-by: Hagen Paul Pfeifer <hagen@jauu.net>

[...]

> diff --git a/misc/ss_json_fmt.c b/misc/ss_json_fmt.c
> index f1a53cd..e80f063 100644
> --- a/misc/ss_json_fmt.c
> +++ b/misc/ss_json_fmt.c
> @@ -161,7 +161,9 @@ static void tcp_stats_json_fmt(struct tcpstat *s)
>   	if (s->rcv_rtt) {
>   		printf(",\n%s\"rcv_rtt\": %g", indent1, s->rcv_rtt);
>   	}
> -
> +	if (s->rcv_space) {
> +		printf(",\n%s\"rcv_space\": %d", indent1, s->rcv_space);
> +	}

    {} not needed. I guess you haven't run your patches thru 
scripts/checkpatch.pl?

WBR, Sergei
