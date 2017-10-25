From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH net] tun: allow positive return values on
 dev_get_valid_name() call
Date: Wed, 25 Oct 2017 13:40:59 -0700
Message-ID: <CAM_iQpXP1zKL=WjBtCxEXmy1k4+QX8AD-QibkEmsSp0xRixBjw@mail.gmail.com>
References: <20171025185050.22102-1-julien@arista.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        David Miller <davem@davemloft.net>
To: Julien Gomes <julien@arista.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f179.google.com ([209.85.192.179]:50899 "EHLO
        mail-pf0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751775AbdJYUlU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 25 Oct 2017 16:41:20 -0400
Received: by mail-pf0-f179.google.com with SMTP id b6so818065pfh.7
        for <netdev@vger.kernel.org>; Wed, 25 Oct 2017 13:41:20 -0700 (PDT)
In-Reply-To: <20171025185050.22102-1-julien@arista.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 25, 2017 at 11:50 AM, Julien Gomes <julien@arista.com> wrote:
> If the name argument of dev_get_valid_name() contains "%d", it will try
> to assign it a unit number in __dev__alloc_name() and return either the
> unit number (>= 0) or an error code (< 0).
> Considering positive values as error values prevent tun device creations
> relying this mechanism, therefor we should only consider negative values
> as errors here.
>
> Signed-off-by: Julien Gomes <julien@arista.com>

Good catch! I missed this case indeed. We'd better document it
in the future.

Acked-by: Cong Wang <xiyou.wangcong@gmail.com>
