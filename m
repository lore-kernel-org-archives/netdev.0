From: Or Gerlitz <gerlitz.or@gmail.com>
Subject: Re: [PATCH net-next 3/9] net/mlx4_core: Set EQ affinity hint to local
 NUMA CPUs
Date: Mon, 16 Jan 2017 23:44:21 +0200
Message-ID: <CAJ3xEMiGQHV1Qc0aW43SJaNO7X5TRLdYRaZgEiA6099vbBAAXw@mail.gmail.com>
References: <1484587805-12666-1-git-send-email-tariqt@mellanox.com> <1484587805-12666-4-git-send-email-tariqt@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
        Linux Netdev List <netdev@vger.kernel.org>,
        Eran Ben Elisha <eranbe@mellanox.com>
To: Tariq Toukan <tariqt@mellanox.com>,
        Daniel Jurgens <danielj@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ot0-f193.google.com ([74.125.82.193]:34513 "EHLO
        mail-ot0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750884AbdAPVpi (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 16 Jan 2017 16:45:38 -0500
Received: by mail-ot0-f193.google.com with SMTP id 73so7534959otj.1
        for <netdev@vger.kernel.org>; Mon, 16 Jan 2017 13:44:22 -0800 (PST)
In-Reply-To: <1484587805-12666-4-git-send-email-tariqt@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 16, 2017 at 7:29 PM, Tariq Toukan <tariqt@mellanox.com> wrote:
> From: Daniel Jurgens <danielj@mellanox.com>
>
> Use CPUs on the close NUMA when setting the EQ affinity hints.

Dan, are we sure there are no down-sides for always doing this? this
code is probably there for many years and we're introducing here new
behaviour to potentially to many Ms installs when they get distro
update that includes this patch.
