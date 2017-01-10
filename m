From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH net-next] net: ipv6: put autoconf routes into
 per-interface tables
Date: Mon, 9 Jan 2017 20:04:36 -0700
Message-ID: <161222cb-5c61-d016-bc0f-2453fb0408b7@cumulusnetworks.com>
References: <20170106153026.24785-1-lorenzo@google.com>
 <37df3b18-d17b-5875-7b44-db40be7b459c@cumulusnetworks.com>
 <CAKD1Yr2U2Oh5yvHE7Znfc9mHzM4K6B_kU82Qctpcsmnt3y5GdQ@mail.gmail.com>
 <e282793e-4057-7fe6-8322-e1899d873ae2@cumulusnetworks.com>
 <CAKD1Yr21W2Ce6mhAqfz+mFUPTn+xn3K_Lz2q5LA27f6V=9tTSQ@mail.gmail.com>
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
Received: from mail-pf0-f178.google.com ([209.85.192.178]:33194 "EHLO
        mail-pf0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932165AbdAJDEi (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 9 Jan 2017 22:04:38 -0500
Received: by mail-pf0-f178.google.com with SMTP id y143so17466640pfb.0
        for <netdev@vger.kernel.org>; Mon, 09 Jan 2017 19:04:38 -0800 (PST)
In-Reply-To: <CAKD1Yr21W2Ce6mhAqfz+mFUPTn+xn3K_Lz2q5LA27f6V=9tTSQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 1/9/17 7:29 PM, Lorenzo Colitti wrote:
> On Tue, Jan 10, 2017 at 11:08 AM, David Ahern <dsa@cumulusnetworks.com> wrote:
>> That's news to me. What about IPv6 and VRF is not working or well-supported?
> 
> I have no firsthand experience of this myself, but if the problems
> that Andrey reports above in this thread are real, then those would
> indicate that the code is not well-supported. Being unable to accept
> DAD is a pretty serious issue. Andrey, what version of the kernel did
> you see this on?
> 

Are you referencing an Android or google thread? This patch thread has not mentioned any IPv6 problems.

Just a day or so ago I did a dup address test on an interface in a vrf and it worked fine, but perhaps I missed something.
