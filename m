From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 00/12] bnxt_en: Add XDP support.
Date: Fri, 03 Feb 2017 16:50:54 -0500 (EST)
Message-ID: <20170203.165054.437855043325795801.davem@davemloft.net>
References: <1486054540-366-1-git-send-email-michael.chan@broadcom.com>
        <20170203.154910.2213640966872850071.davem@davemloft.net>
        <CACKFLimXCkC1=9kvQnz-s5rjTOGe1gmb9Ozvt1tEeW+O=y7yAg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: michael.chan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:55262 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752469AbdBCVu4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 3 Feb 2017 16:50:56 -0500
In-Reply-To: <CACKFLimXCkC1=9kvQnz-s5rjTOGe1gmb9Ozvt1tEeW+O=y7yAg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Michael Chan <michael.chan@broadcom.com>
Date: Fri, 3 Feb 2017 13:13:47 -0800

> On Fri, Feb 3, 2017 at 12:49 PM, David Miller <davem@davemloft.net> wrote:
>>
>> Please _DO NOT_ guard XDP support with an ifdef the user
>> can modify.
>>
>> Treat it like any other common netdev feature a driver might
>> support such as checksum offloading or GRO.
>>
> 
> David, I want to make sure I understand completely.  Are you saying
> don't use Kconfig option for XDP?  Have it always available?

Yes.

I don't see a similar config option used in any other driver.

What's really driving me completely mad about driver XDP adoption
is that there is so much inconsistency.

If you do not see another XDP supporting driver do something, don't be
tempted to blaze your own trail and handle something in a unique way.

We don't set precedence by one driver saying "hey it's better to do
things this way, forget what all the other drivers are doing."  Rather
we have a "discussion" about what the appropriate thing is to do and
convert all the drivers only after a decision has been made.

Meanwhile we keep the status quo.
