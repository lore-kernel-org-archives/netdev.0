From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH 1/1] tools: net: bpf_dbg.c fixed keyboard typo
Date: Fri, 16 Dec 2016 20:31:57 +0100
Message-ID: <5854412D.9060804@iogearbox.net>
References: <5194151481912505@web1g.yandex.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel <linux-kernel@vger.kernel.org>,
        netdev <netdev@vger.kernel.org>
To: Ozgur Karatas <okaratas@member.fsf.org>,
        David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:55930 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756215AbcLPTcC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 16 Dec 2016 14:32:02 -0500
In-Reply-To: <5194151481912505@web1g.yandex.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/16/2016 07:21 PM, Ozgur Karatas wrote:
>
> This patch fixed to keyboard typo, brackets not closed.
> I think, it should be close to parenthes.
>
> Signed-off-by: Ozgur Karatas <okaratas@member.fsf.org>

NAK for obvious reasons ...

> ---
>   tools/net/bpf_dbg.c       | 2 +-
>   1 files changed, 1 insertion(+), 1 deletions(-)
>
> diff --git a/tools/net/bpf_dbg.c b/tools/net/bpf_dbg.c
> index 4f254bc..f715f46 100644
> --- a/tools/net/bpf_dbg.c
> +++ b/tools/net/bpf_dbg.c
> @@ -1213,7 +1213,7 @@ static int cmd_disassemble(char *line_string)
>
>   	if (!bpf_prog_loaded())
>   		return CMD_ERR;
> -	if (strlen(line_string) > 0 &&
> +	if (strlen(line_string) > 0 &&)
>   	    (line = strtoul(line_string, NULL, 10)) < bpf_prog_len)
>   		single_line = true;
>   	if (single_line)
>
