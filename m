From: Liping Zhang <zlpnobody@gmail.com>
Subject: Re: [PATCH] net: netfilter: Replace explicit NULL comparisons
Date: Sun, 9 Apr 2017 17:36:22 +0800
Message-ID: <CAML_gOeX=c9AxpuFBGes_ogQSZe+s1Rg3-rBL1Q4RX9Gv5hcZg@mail.gmail.com>
References: <20170408172113.GA9352@arushi-HP-Pavilion-Notebook>
 <nycvar.YFH.7.76.1704082020530.14011@n3.vanv.qr> <20170408201438.GC2679@salvia>
 <CA+XqjF_8=+GB7oq6wKoxk_+FfPeni+tLaVMAE6k6tP-KOOEi6Q@mail.gmail.com> <nycvar.YFH.7.76.1704091025350.18194@n3.vanv.qr>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Arushi Singhal <arushisinghal19971997@gmail.com>,
        Pablo Neira Ayuso <pablo@netfilter.org>,
        Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
        "David S. Miller" <davem@davemloft.net>,
        Netfilter Developer Mailing List
        <netfilter-devel@vger.kernel.org>, coreteam@netfilter.org,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>
To: Jan Engelhardt <jengelh@inai.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ua0-f193.google.com ([209.85.217.193]:34701 "EHLO
        mail-ua0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752137AbdDIJgY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 9 Apr 2017 05:36:24 -0400
In-Reply-To: <nycvar.YFH.7.76.1704091025350.18194@n3.vanv.qr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2017-04-09 16:26 GMT+08:00 Jan Engelhardt <jengelh@inai.de>:
>
> On Sunday 2017-04-09 05:42, Arushi Singhal wrote:
>>On Sun, Apr 9, 2017 at 1:44 AM, Pablo Neira Ayuso <pablo@netfilter.org> wrote:
>>      On Sat, Apr 08, 2017 at 08:21:56PM +0200, Jan Engelhardt wrote:
>>      > On Saturday 2017-04-08 19:21, Arushi Singhal wrote:
>>      >
>>      > >Replace explicit NULL comparison with ! operator to simplify code.
>>      >
>>      > I still wouldn't do this, for the same reason as before. Comparing to
>>      > NULL explicitly more or less gave an extra guarantee that the other
>>      > operand was also a pointer.
>>
>>      Arushi, where does it say in the coding style that this is prefered?
>>
>>This is reported by checkpatch.pl script.
>
> checkpatch has been controversial at times, like when people took the 80
> character limit way too literally. Changing pointer comparisons looks like
> another thing that is better left ignored.

Yes, I agree too. Converting the "if (p != NULL)" to "if (p)" like this seems
unnecessary.
