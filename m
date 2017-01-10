From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH net-next] net: ipv6: put autoconf routes into
 per-interface tables
Date: Mon, 9 Jan 2017 20:39:43 -0700
Message-ID: <bbcab8bb-6a2a-6b90-f6a2-ad840a2c389c@cumulusnetworks.com>
References: <20170106153026.24785-1-lorenzo@google.com>
 <37df3b18-d17b-5875-7b44-db40be7b459c@cumulusnetworks.com>
 <CAKD1Yr2U2Oh5yvHE7Znfc9mHzM4K6B_kU82Qctpcsmnt3y5GdQ@mail.gmail.com>
 <e282793e-4057-7fe6-8322-e1899d873ae2@cumulusnetworks.com>
 <CAKD1Yr21W2Ce6mhAqfz+mFUPTn+xn3K_Lz2q5LA27f6V=9tTSQ@mail.gmail.com>
 <161222cb-5c61-d016-bc0f-2453fb0408b7@cumulusnetworks.com>
 <CAKD1Yr0BnYNTYtCBHLy=KuhX3_23p8eQst61CoC0BHEr5PVkjQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        =?UTF-8?Q?Maciej_=c5=bbenczykowski?= <zenczykowski@gmail.com>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>,
        Erik Kline <ek@google.com>,
        YOSHIFUJI Hideaki <hideaki.yoshifuji@miraclelinux.com>,
        David Miller <davem@davemloft.net>,
        Daniel Rosenberg <drosen@google.com>, temnota.am@gmail.com
To: Lorenzo Colitti <lorenzo@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f171.google.com ([209.85.192.171]:36729 "EHLO
        mail-pf0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755369AbdAJDjq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 9 Jan 2017 22:39:46 -0500
Received: by mail-pf0-f171.google.com with SMTP id 189so26474655pfu.3
        for <netdev@vger.kernel.org>; Mon, 09 Jan 2017 19:39:45 -0800 (PST)
In-Reply-To: <CAKD1Yr0BnYNTYtCBHLy=KuhX3_23p8eQst61CoC0BHEr5PVkjQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 1/9/17 8:30 PM, Lorenzo Colitti wrote:
> On Tue, Jan 10, 2017 at 12:04 PM, David Ahern <dsa@cumulusnetworks.com> wrote:
>>> I have no firsthand experience of this myself, but if the problems
>>> that Andrey reports above in this thread are real, then those would
>>> indicate that the code is not well-supported. Being unable to accept
>>> DAD is a pretty serious issue. Andrey, what version of the kernel did
>>> you see this on?
>>
>> Are you referencing an Android or google thread? This patch thread has not mentioned any IPv6 problems.
> 
> No, this thread. I see message-ID 8cddkd-etc.ln1@banana.localnet in
> this thread. If you didn't get it, I also see it in the comments on
> patchwork - https://patchwork.ozlabs.org/patch/711956/
> 

Odd that I did not get that -- checked spam and trash.

Andrey is missing 830218c1add1da16519b71909e5cf21522b7d062 which tells me the comment is not based on 4.10 or net-next:

$ git describe 830218c1add1da16519b71909e5cf21522b7d062
v4.8-14744-g830218c1add1
