From: Or Gerlitz <gerlitz.or@gmail.com>
Subject: Re: [PATCH net-next 1/6] net/mlx5e: Support DCBX CEE API
Date: Tue, 30 Aug 2016 23:33:06 +0300
Message-ID: <CAJ3xEMhKWh1_X9-SWdQHEGSUH0Z1EejCMLTXgyFizZ+-hU7Y8g@mail.gmail.com>
References: <1472556595-9286-1-git-send-email-saeedm@mellanox.com> <1472556595-9286-2-git-send-email-saeedm@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
        Linux Netdev List <netdev@vger.kernel.org>,
        Saeed Mahameed <saeedm@mellanox.com>
To: Huy Nguyen <huyn@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f66.google.com ([209.85.218.66]:35950 "EHLO
        mail-oi0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752054AbcH3UdH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 30 Aug 2016 16:33:07 -0400
Received: by mail-oi0-f66.google.com with SMTP id b22so2810001oii.3
        for <netdev@vger.kernel.org>; Tue, 30 Aug 2016 13:33:07 -0700 (PDT)
In-Reply-To: <1472556595-9286-2-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 30, 2016 at 2:29 PM, Saeed Mahameed <saeedm@mellanox.com> wrote:
> From: Huy Nguyen <huyn@mellanox.com>
>
> Add DCBX CEE API interface for CX4. Configurations are stored in a
> temporary structure and are applied to the card's firmware when the
> CEE's setall callback function is called.
>
> Note:
>   priority group in CEE is equivalent to traffic class in ConnectX-4
>   hardware spec.
>
>   bw allocation per priority in CEE is not supported because CX4
>   only supports bw allocation per traffic class.
>
>   user priority in CEE does not have an equivalent term in CX4.
>   Therefore, user priority to priority mapping in CEE is not supported.

basically our drivers suits (mlx4/5) are not written to a certain HW,
but rather to multiple (past, present and future) brands using dev
caps advertized by the firmware towards the driver.

I see here lots of CX4 explicit mentioning... so (1) try to avoid it
or make the description more general (2) do you base your code on dev
caps or hard coded assumptions?


> Test: see DCBX_LinuxDriverCX4 document section 6.4

what's the relevancy for the upstream commit change log?

> Signed-off-by: Huy Nguyen <huyn@mellanox.com>
> Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
