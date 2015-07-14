From: Tom Herbert <tom@herbertland.com>
Subject: Re: [PATCH net-next 2/3] rhashtable: allow lookup function to have
 compare function agument
Date: Tue, 14 Jul 2015 08:43:52 -0700
Message-ID: <CALx6S35rcBJtLeUQEnD3yc3nY2HC_KW_3b+pb8RFHt=GTx1Zng@mail.gmail.com>
References: <1436834353-1851565-1-git-send-email-tom@herbertland.com>
	<1436834353-1851565-3-git-send-email-tom@herbertland.com>
	<20150714094449.GD20597@pox.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Kernel Team <kernel-team@fb.com>,
	Herbert Xu <herbert@gondor.apana.org.au>
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f178.google.com ([209.85.223.178]:35391 "EHLO
	mail-ie0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751900AbbGNPnx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Jul 2015 11:43:53 -0400
Received: by iecuq6 with SMTP id uq6so14136665iec.2
        for <netdev@vger.kernel.org>; Tue, 14 Jul 2015 08:43:53 -0700 (PDT)
In-Reply-To: <20150714094449.GD20597@pox.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 14, 2015 at 2:44 AM, Thomas Graf <tgraf@suug.ch> wrote:
> On 07/13/15 at 05:39pm, Tom Herbert wrote:
>> Added rhashtable_lookup_fast_cmpfn which does a lookup in an rhash table
>> with the compare function being taken from an argument. This allows
>> different compare functions to be used on the same table.
>>
>> Signed-off-by: Tom Herbert <tom@herbertland.com>
>
> Does this preserve the inlining guarantee? I remember Herbert had
> to write this carefully in order to avoid indirect calls.

It looks like the compare functions are still being properly inlined.
This is gcc 4.4.7.

Thanks,
Tom
