From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: Re: [PATCH net] net: rtnetlink: fix info leak in RTM_GETSTATS call
Date: Tue, 3 Oct 2017 07:18:07 -0700
Message-ID: <CAJieiUiRy8=KDNL7vj63V97cSoYdcQB3Q3hfnX+_YevVgnd3Xw@mail.gmail.com>
References: <1507026048-13734-1-git-send-email-nikolay@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        keescook@chromium.org, Dmitry Vyukov <dvyukov@google.com>,
        Andrey Konovalov <andreyknvl@google.com>,
        Kostya Serebryany <kcc@google.com>,
        Alexander Potapenko <glider@google.com>,
        "davem@davemloft.net" <davem@davemloft.net>,
        Eric Dumazet <edumazet@google.com>
To: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vk0-f41.google.com ([209.85.213.41]:44172 "EHLO
        mail-vk0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751156AbdJCOSI (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 3 Oct 2017 10:18:08 -0400
Received: by mail-vk0-f41.google.com with SMTP id d12so4662235vkf.1
        for <netdev@vger.kernel.org>; Tue, 03 Oct 2017 07:18:08 -0700 (PDT)
In-Reply-To: <1507026048-13734-1-git-send-email-nikolay@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 3, 2017 at 3:20 AM, Nikolay Aleksandrov
<nikolay@cumulusnetworks.com> wrote:
> When RTM_GETSTATS was added the fields of its header struct were not all
> initialized when returning the result thus leaking 4 bytes of information
> to user-space per rtnl_fill_statsinfo call, so initialize them now. Thanks
> to Alexander Potapenko for the detailed report and bisection.
>
> Reported-by: Alexander Potapenko <glider@google.com>
> Fixes: 10c9ead9f3c6 ("rtnetlink: add new RTM_GETSTATS message to dump link stats")
> Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>

Acked-by: Roopa Prabhu <roopa@cumulusnetworks.com>

Thanks Nikolay!.
