From: Saeed Mahameed <saeedm@dev.mellanox.co.il>
Subject: Re: [PATCH net v2] net/mlx4_en: don't set CHECKSUM_COMPLETE on SCTP packets
Date: Tue, 8 Aug 2017 19:16:52 +0300
Message-ID: <CALzJLG-Xp1TeYQBm6bwOmGxbtzMp0ohmLOY+iMCg1U9QcC791Q@mail.gmail.com>
References: <23ac3e005a8dc1a373971f1166fe6ba72d8abe4b.1501793448.git.dcaratti@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Tariq Toukan <tariqt@mellanox.com>,
        Linux Netdev List <netdev@vger.kernel.org>,
        "David S . Miller" <davem@davemloft.net>
To: Davide Caratti <dcaratti@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ua0-f177.google.com ([209.85.217.177]:33450 "EHLO
        mail-ua0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752070AbdHHQRN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 8 Aug 2017 12:17:13 -0400
Received: by mail-ua0-f177.google.com with SMTP id 80so17301355uas.0
        for <netdev@vger.kernel.org>; Tue, 08 Aug 2017 09:17:12 -0700 (PDT)
In-Reply-To: <23ac3e005a8dc1a373971f1166fe6ba72d8abe4b.1501793448.git.dcaratti@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 3, 2017 at 11:54 PM, Davide Caratti <dcaratti@redhat.com> wrote:
> if the NIC fails to validate the checksum on TCP/UDP, and validation of IP
> checksum is successful, the driver subtracts the pseudo-header checksum
> from the value obtained by the hardware and sets CHECKSUM_COMPLETE. Don't
> do that if protocol is IPPROTO_SCTP, otherwise CRC32c validation fails.
>
> V2: don't test MLX4_CQE_STATUS_IPV6 if MLX4_CQE_STATUS_IPV4 is set
>
> Reported-by: Shuang Li <shuali@redhat.com>
> Fixes: f8c6455bb04b ("net/mlx4_en: Extend checksum offloading by CHECKSUM COMPLETE")
> Signed-off-by: Davide Caratti <dcaratti@redhat.com>

Acked-by: Saeed Mahameed <saeedm@mellanox.com>
