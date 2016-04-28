From: Tom Herbert <tom@herbertland.com>
Subject: Re: [RFC PATCH net] ipv6/ila: fix nlsize calculation for lwtunnel
Date: Thu, 28 Apr 2016 09:07:25 -0700
Message-ID: <CALx6S36jkPqx5U+B9akRYZ+xiRhozk_AdOmKBEr4N9mhwTKQMw@mail.gmail.com>
References: <1461340682-31568-1-git-send-email-nicolas.dichtel@6wind.com>
	<20160427.152053.2243888701043810040.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f176.google.com ([209.85.213.176]:36043 "EHLO
	mail-ig0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752067AbcD1QH1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Apr 2016 12:07:27 -0400
Received: by mail-ig0-f176.google.com with SMTP id u10so108338419igr.1
        for <netdev@vger.kernel.org>; Thu, 28 Apr 2016 09:07:26 -0700 (PDT)
In-Reply-To: <20160427.152053.2243888701043810040.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 27, 2016 at 12:20 PM, David Miller <davem@davemloft.net> wrote:
> From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
> Date: Fri, 22 Apr 2016 17:58:02 +0200
>
>> The handler 'ila_fill_encap_info' adds one attribute: ILA_ATTR_LOCATOR.
>>
>> Fixes: 65d7ab8de582 ("net: Identifier Locator Addressing module")
>> CC: Tom Herbert <tom@herbertland.com>
>> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
>> ---
>>
>> Tom, when I read the comment, I feel I'm misssing something, but what?
>
> Tom, seriously, please look at this.
>
Yes, it is an issue. Need to do add size for ILA_ATTR_LOCATOR and
ILA_ATTR_CSUM_MODE. Also not we made ILA_ATTR_CSUM_MODE u64 in fill
encap info. I will send a path shortly.

> And with recent changes in net-next the csum attribute size needs to
> be specified as well, plus the locator needs to use the 64-bit
> alignment sizing helper.

Something other than nla_put_u64_64bit?

Thanks,
Tom
