From: Saeed Mahameed <saeedm@dev.mellanox.co.il>
Subject: Re: [PATCH net v2] mlx4: Return EOPNOTSUPP instead of ENOTSUPP
Date: Tue, 10 Jan 2017 22:04:55 +0200
Message-ID: <CALzJLG99semMYGKMO1QvNg1EK0m-uFWv4+-o45oV9t3QoY6_rw@mail.gmail.com>
References: <1484070109-105991-1-git-send-email-kafai@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Netdev List <netdev@vger.kernel.org>,
        Saeed Mahameed <saeedm@mellanox.com>,
        Tariq Toukan <tariqt@mellanox.com>,
        Kernel Team <kernel-team@fb.com>
To: Martin KaFai Lau <kafai@fb.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f195.google.com ([209.85.220.195]:35686 "EHLO
        mail-qk0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S965855AbdAJUFR (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 10 Jan 2017 15:05:17 -0500
Received: by mail-qk0-f195.google.com with SMTP id u25so77585539qki.2
        for <netdev@vger.kernel.org>; Tue, 10 Jan 2017 12:05:16 -0800 (PST)
In-Reply-To: <1484070109-105991-1-git-send-email-kafai@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 10, 2017 at 7:41 PM, Martin KaFai Lau <kafai@fb.com> wrote:
> In commit b45f0674b997 ("mlx4: xdp: Allow raising MTU up to one page minus eth and vlan hdrs"),
> it changed EOPNOTSUPP to ENOTSUPP by mistake.  This patch fixes it.
>
> Fixes: b45f0674b997 ("mlx4: xdp: Allow raising MTU up to one page minus eth and vlan hdrs")
> Signed-off-by: Martin KaFai Lau <kafai@fb.com>

Acked-by: Saeed Mahameed <saeedm@mellanox.com>


Thank you martin.

Small question though,
is it essential for the upper layer to get the correct errno ? or this
is just a cleanup ?
