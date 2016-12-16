From: Ozgur Karatas <okaratas@member.fsf.org>
Subject: Re: [PATCH 1/1] tools: net: bpf_dbg.c fixed keyboard typo
Date: Fri, 16 Dec 2016 21:13:06 +0200
Message-ID: <142441481915586@web39j.yandex.ru>
References: <5194151481912505@web1g.yandex.ru> <96578fd4-dd02-f39a-a252-c37aa714d3d0@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: linux-kernel <linux-kernel@vger.kernel.org>,
        netdev <netdev@vger.kernel.org>
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
        David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from forward5p.cmail.yandex.net ([77.88.31.20]:33035 "EHLO
        forward5p.cmail.yandex.net" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1752630AbcLPTPE (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 16 Dec 2016 14:15:04 -0500
In-Reply-To: <96578fd4-dd02-f39a-a252-c37aa714d3d0@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



16.12.2016, 21:08, "Sergei Shtylyov" <sergei.shtylyov@cogentembedded.com>:
> Hello.

Hi

> On 12/16/2016 09:21 PM, Ozgur Karatas wrote:
>
>>  This patch fixed to keyboard typo, brackets not closed.
>>  I think, it should be close to parenthes.
>>
>>  Signed-off-by: Ozgur Karatas <okaratas@member.fsf.org>
>>  ---
>>   tools/net/bpf_dbg.c | 2 +-
>>   1 files changed, 1 insertion(+), 1 deletions(-)
>>
>>  diff --git a/tools/net/bpf_dbg.c b/tools/net/bpf_dbg.c
>>  index 4f254bc..f715f46 100644
>>  --- a/tools/net/bpf_dbg.c
>>  +++ b/tools/net/bpf_dbg.c
>>  @@ -1213,7 +1213,7 @@ static int cmd_disassemble(char *line_string)
>>
>>           if (!bpf_prog_loaded())
>>                   return CMD_ERR;
>>  - if (strlen(line_string) > 0 &&
>>  + if (strlen(line_string) > 0 &&)
>
>     Have tried to you compile that? :-/

Yes, i compiled but I apologize if there was NAK.
Also, checkpatch give a error.

I could be wrong, will review again.

Best Regards!

>>               (line = strtoul(line_string, NULL, 10)) < bpf_prog_len)
>
>     I think the code was correct before your patch...
>
>>                   single_line = true;
>>           if (single_line)
>
> MBR, Sergei

~Ozgur
