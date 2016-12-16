From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH 1/1] tools: net: bpf_dbg.c fixed keyboard typo
Date: Fri, 16 Dec 2016 22:08:17 +0300
Message-ID: <96578fd4-dd02-f39a-a252-c37aa714d3d0@cogentembedded.com>
References: <5194151481912505@web1g.yandex.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel <linux-kernel@vger.kernel.org>,
        netdev <netdev@vger.kernel.org>
To: Ozgur Karatas <okaratas@member.fsf.org>,
        David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f53.google.com ([209.85.215.53]:35155 "EHLO
        mail-lf0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1758286AbcLPTIW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 16 Dec 2016 14:08:22 -0500
Received: by mail-lf0-f53.google.com with SMTP id b14so14535460lfg.2
        for <netdev@vger.kernel.org>; Fri, 16 Dec 2016 11:08:21 -0800 (PST)
In-Reply-To: <5194151481912505@web1g.yandex.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 12/16/2016 09:21 PM, Ozgur Karatas wrote:

> This patch fixed to keyboard typo, brackets not closed.
> I think, it should be close to parenthes.
>
> Signed-off-by: Ozgur Karatas <okaratas@member.fsf.org>
> ---
>  tools/net/bpf_dbg.c       | 2 +-
>  1 files changed, 1 insertion(+), 1 deletions(-)
>
> diff --git a/tools/net/bpf_dbg.c b/tools/net/bpf_dbg.c
> index 4f254bc..f715f46 100644
> --- a/tools/net/bpf_dbg.c
> +++ b/tools/net/bpf_dbg.c
> @@ -1213,7 +1213,7 @@ static int cmd_disassemble(char *line_string)
>
>  	if (!bpf_prog_loaded())
>  		return CMD_ERR;
> -	if (strlen(line_string) > 0 &&
> +	if (strlen(line_string) > 0 &&)

    Have tried to you compile that? :-/

>  	    (line = strtoul(line_string, NULL, 10)) < bpf_prog_len)

    I think the code was correct before your patch...

>  		single_line = true;
>  	if (single_line)

MBR, Sergei
