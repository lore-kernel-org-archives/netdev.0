From: Ozgur Karatas <okaratas@member.fsf.org>
Subject: Re: [PATCH 1/1] tools: net: bpf_dbg.c fixed keyboard typo
Date: Fri, 16 Dec 2016 20:58:43 +0200
Message-ID: <5466381481914723@web9h.yandex.ru>
References: <5194151481912505@web1g.yandex.ru> <1481913321.29291.89.camel@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: linux-kernel <linux-kernel@vger.kernel.org>,
        netdev <netdev@vger.kernel.org>
To: Joe Perches <joe@perches.com>, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from forward3h.cmail.yandex.net ([87.250.230.18]:54424 "EHLO
        forward3h.cmail.yandex.net" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751014AbcLPS6r (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 16 Dec 2016 13:58:47 -0500
In-Reply-To: <1481913321.29291.89.camel@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

16.12.2016, 20:35, "Joe Perches" <joe@perches.com>:
> On Fri, 2016-12-16 at 20:21 +0200, Ozgur Karatas wrote:
>>  This patch fixed to keyboard typo, brackets not closed.
>>  I think, it should be close to parenthes.
>
> No.
>
> Please compile and test your patches on your own system
> before you send them.

Also, checkpatch script give a error, it should not forget.

$ ./scripts/checkpatch.pl --file --terse tools/net/bpf_dbg.c
tools/net/bpf_dbg.c:1216: ERROR: do not use assignment in if condition

After fix:

$ ./scripts/checkpatch.pl --file --terse tools/net/bpf_dbg.c 
total: 0 errors, 6 warnings, 1395 lines checked

Regards,

~Ozgur
