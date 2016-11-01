From: Joachim Eastwood <manabian@gmail.com>
Subject: Re: [net-next PATCH 0/7] stmmac: dwmac-sti refactor+cleanup
Date: Tue, 1 Nov 2016 18:00:35 +0100
Message-ID: <CAGhQ9VxPsvY4F5u93MZpu280JgLiGUTdqrKdrXw6TOPK9x7Atg@mail.gmail.com>
References: <20161030200507.851-1-manabian@gmail.com> <20161031.154726.460941249322981922.davem@davemloft.net>
 <20161101.115634.415403364673533569.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "peppe.cavallaro" <peppe.cavallaro@st.com>,
        alexandre.torgue@st.com, netdev <netdev@vger.kernel.org>,
        kernel@stlinux.com
To: David Miller <davem@davemloft.net>,
        Patrice Chotard <patrice.chotard@st.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f65.google.com ([209.85.218.65]:34135 "EHLO
        mail-oi0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752833AbcKARAh (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 1 Nov 2016 13:00:37 -0400
Received: by mail-oi0-f65.google.com with SMTP id 62so14942306oif.1
        for <netdev@vger.kernel.org>; Tue, 01 Nov 2016 10:00:36 -0700 (PDT)
In-Reply-To: <20161101.115634.415403364673533569.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On 1 November 2016 at 16:56, David Miller <davem@davemloft.net> wrote:
> From: David Miller <davem@davemloft.net>
> Date: Mon, 31 Oct 2016 15:47:26 -0400 (EDT)
>
>> From: Joachim Eastwood <manabian@gmail.com>
>> Date: Sun, 30 Oct 2016 21:05:00 +0100
>>
>>> This patch set aims to remove the init/exit callbacks from the
>>> dwmac-sti driver and instead use standard PM callbacks. Doing this
>>> will also allow us to cleanup the driver.
>>>
>>> Eventually the init/exit callbacks will be deprecated and removed
>>> from all drivers dwmac-* except for dwmac-generic. Drivers will be
>>> refactored to use standard PM and remove callbacks.
>>>
>>> Note that this patch set has only been test compiled and no functional
>>> change is intended.
>>
>> I would really like to see some review and testing before applying this
>> series.
>
> Ping?

Adding some more ST people.

Could anyone with a stih407 platform please give these patches a try?

The series can found at https://github.com/manabian/linux-lpc.git in
the net-sti-dwmac branch (based on net-next).
Alternatively they can also be picked from netdev's patchwork.


regards,
Joachim Eastwood
