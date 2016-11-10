From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH] genetlink: fix unsigned int comparison with less than zero
Date: Thu, 10 Nov 2016 09:11:29 -0800
Message-ID: <CAM_iQpW=q4nm97dNouSL19Cr2cEWT9xQHXAm4CNJk=AY8z_2MA@mail.gmail.com>
References: <20161110155758.26996-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S . Miller" <davem@davemloft.net>,
        Johannes Berg <johannes.berg@intel.com>,
        pravin shelar <pshelar@ovn.org>,
        Wei Yongjun <weiyongjun1@huawei.com>,
        Florian Westphal <fw@strlen.de>,
        Tycho Andersen <tycho.andersen@canonical.com>,
        Tom Herbert <tom@herbertland.com>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>
To: Colin King <colin.king@canonical.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f41.google.com ([209.85.214.41]:35846 "EHLO
        mail-it0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934264AbcKJRLv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 10 Nov 2016 12:11:51 -0500
In-Reply-To: <20161110155758.26996-1-colin.king@canonical.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Nov 10, 2016 at 7:57 AM, Colin King <colin.king@canonical.com> wrote:
> From: Colin Ian King <colin.king@canonical.com>
>
> family->id is unsigned, so the less than zero check for
> failure return from idr_alloc is never true and so the error exit
> is never handled.  Instead, assign err and check if this is less
> than zero since this is a signed integer.

Why family->id can't be just signed int? For me it should be.
