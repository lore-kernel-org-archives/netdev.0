From: Or Gerlitz <gerlitz.or@gmail.com>
Subject: Re: [PATCH net-next V2 3/6] net/mlx5e: Read ETS settings directly
 from firmware
Date: Tue, 6 Sep 2016 19:26:08 +0300
Message-ID: <CAJ3xEMiwKF9gLXx+uzPoHdg1O7HijPy0zSMTj25sh+jXqFW4CQ@mail.gmail.com>
References: <1473177852-10711-1-git-send-email-saeedm@mellanox.com> <1473177852-10711-4-git-send-email-saeedm@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
        Linux Netdev List <netdev@vger.kernel.org>,
        Or Gerlitz <ogerlitz@mellanox.com>
To: Saeed Mahameed <saeedm@mellanox.com>,
        Huy Nguyen <huyn@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f44.google.com ([209.85.218.44]:32922 "EHLO
        mail-oi0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932327AbcIFQ0K (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 6 Sep 2016 12:26:10 -0400
Received: by mail-oi0-f44.google.com with SMTP id y2so80477551oie.0
        for <netdev@vger.kernel.org>; Tue, 06 Sep 2016 09:26:10 -0700 (PDT)
In-Reply-To: <1473177852-10711-4-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 6, 2016 at 7:04 PM, Saeed Mahameed <saeedm@mellanox.com> wrote:
> From: Huy Nguyen <huyn@mellanox.com>
>
> Issue description:
> Current implementation saves the ETS settings from user in
> a temporal soft copy and returns this settings when user
> queries the ETS settings.
>
> With the new DCBX firmware, the ETS settings can be changed
> by firmware when the DCBX is in firmware controlled mode. Therefore,
> user will obtain wrong values from the temporal soft copy.

Can this happen also with V2? I thought that when you dropped the
private flag it means that this hybrid mode
isn't exposed now, please clarify.
