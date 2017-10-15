From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next 00/10] korina cleanups/optimizations
Date: Sun, 15 Oct 2017 10:36:52 -0700
Message-ID: <D5237C2A-B301-46E1-B2B6-66DCA637E87F@gmail.com>
References: <20171015162226.606-1-roman@advem.lv> <0FA80CB3-C0DC-4B30-B638-26B5D46AE69E@gmail.com> <c3a2f516dcceb7dee9ea4dde634b58ed@advem.lv>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: quoted-printable
To: Roman Yeryomin <roman@advem.lv>, netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f65.google.com ([209.85.218.65]:52085 "EHLO
        mail-oi0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751210AbdJOSIe (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 15 Oct 2017 14:08:34 -0400
Received: by mail-oi0-f65.google.com with SMTP id j126so21533152oib.8
        for <netdev@vger.kernel.org>; Sun, 15 Oct 2017 11:08:34 -0700 (PDT)
In-Reply-To: <c3a2f516dcceb7dee9ea4dde634b58ed@advem.lv>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On October 15, 2017 9:46:02 AM PDT, Roman Yeryomin <roman@advem=2Elv> wrote=
:
>On 2017-10-15 19:38, Florian Fainelli wrote:
>> On October 15, 2017 9:22:26 AM PDT, Roman Yeryomin <roman@advem=2Elv>=
=20
>> wrote:
>>> TX optimizations have led to ~15% performance increase (35->40Mbps)
>>> in local tx usecase (tested with iperf v3=2E2)=2E
>>=20
>> Could you avoid empty commit messages and write a paragraph or two
>for
>> each commit that explains what and why are you changing? The changes
>> look fine but they lack any explanation=2E
>
>I thought that short descriptions are already self explanatory and just
>
>didn't know what to write more=2E
>To me they are very obvious=2E

You can't assume what is obvious to you will be to the reviewers=2E

>Do you really want me to make up something more?

It's up to David as a maintainer to decide, but if this was up to me I wou=
ld ask you to respin with a least a paragraph for each commit (except the v=
ersion bump) why you did these changes=2E

>
>>>=20
>>> Roman Yeryomin (10):
>>>  net: korina: optimize korina_send_packet logic
>>>  net: korina: reorder functions
>>>  net: korina: introduce and use interrupt disable/enable helpers
>>>  net: korina: optimize tx/rx interrupt handlers
>>>  net: korina: remove unused korina_private members
>>>  net: korina: optimize tx descriptor flags processing
>>>  net: korina: move tx to napi context
>>>  net: korina: optimize tx_full condition
>>>  net: korina: use dma api instead of dma_cache_* functions
>>>  net: korina: bump version
>>>=20
>>> drivers/net/ethernet/korina=2Ec | 503
>>> +++++++++++++++++-------------------------
>>> 1 file changed, 204 insertions(+), 299 deletions(-)


--=20
Florian
