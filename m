From: Vadim Kochan <vadim4j@gmail.com>
Subject: Re: [PATCH] iproute2: Refactor: using new nl_msg struct for the all
 Netlink handlers
Date: Thu, 4 Sep 2014 08:39:15 +0300
Message-ID: <CAMw6YJJ1z6TC76q-nWc8rmmRjOcLT1g7uBoag3kO4wsfZ3X3_Q@mail.gmail.com>
References: <1409777224-7813-1-git-send-email-vadim4j@gmail.com>
	<20140903183349.0209942d@urahara>
	<CAMw6YJJHRet+Z_855OEpDaAYfiVUgORo8T0p_XF2p-WN6fiYdg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: Stephen Hemminger <stephen@networkplumber.org>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f50.google.com ([209.85.216.50]:48176 "EHLO
	mail-qa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751068AbaIDFjP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Sep 2014 01:39:15 -0400
Received: by mail-qa0-f50.google.com with SMTP id cm18so8745262qab.23
        for <netdev@vger.kernel.org>; Wed, 03 Sep 2014 22:39:15 -0700 (PDT)
In-Reply-To: <CAMw6YJJHRet+Z_855OEpDaAYfiVUgORo8T0p_XF2p-WN6fiYdg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

+netdev@vger.kernel.org

On Thu, Sep 4, 2014 at 8:33 AM, Vadim Kochan <vadim4j@gmail.com> wrote:
> I think that even if convert iproute2 to some other lib it would be
> good to have some custome struct which
> would be used by handlers.
>
> On Thu, Sep 4, 2014 at 4:33 AM, Stephen Hemminger
> <stephen@networkplumber.org> wrote:
>> On Wed,  3 Sep 2014 23:47:04 +0300
>> Vadim Kochan <vadim4j@gmail.com> wrote:
>>
>>> It will easy to extend with new parameters in future.
>>>
>>> Signed-off-by: Vadim Kochan <vadim4j@gmail.com>
>>
>> Rather than go to all this effort, lets just convert iproute2 to use
>> a sane netlink library like libmnl.
>>
