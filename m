From: Ozgur Karatas <okaratas@member.fsf.org>
Subject: Re: [PATCH 1/1] tools: net: bpf_dbg.c fixed keyboard typo
Date: Fri, 16 Dec 2016 20:53:44 +0200
Message-ID: <5201261481914424@web9g.yandex.ru>
References: <5194151481912505@web1g.yandex.ru> <1481913321.29291.89.camel@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: linux-kernel <linux-kernel@vger.kernel.org>,
        netdev <netdev@vger.kernel.org>
To: Joe Perches <joe@perches.com>, David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1481913321.29291.89.camel@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

16.12.2016, 20:35, "Joe Perches" <joe@perches.com>:
> On Fri, 2016-12-16 at 20:21 +0200, Ozgur Karatas wrote:
>>  This patch fixed to keyboard typo, brackets not closed.
>>  I think, it should be close to parenthes.
>
> No.
>
> Please compile and test your patches on your own system
> before you send them.

Dear Perches,

I have already tested and it was not a part of the code anyway. if there is no parentheses, the code works incorrectly and give a error. 
I'm sorry, have a little problem with my english but "line_string" variables would not equal NULL, 10. So the code it skips it and runs to "bpf_prog_len".
If it should be equal "0 &&" and already be completed (>) right?

if (strlen(line_string) > 0 &&
            (line = strtoul(line_string, NULL, 10)) < bpf_prog_len)

Testing:

$ make M=tools/
tools//Makefile:6: scripts/Makefile.include: No such file or directory
$ cp tools/scripts/Makefile.include scripts/Makefile
$ make M=tools/
  Building modules, stage 2.
  MODPOST 0 modules

I try to module (insmod) and worked.

Regards,

 ~Ozgur
