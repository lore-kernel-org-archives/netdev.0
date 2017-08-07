From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v2] net/mlx4_en: don't set CHECKSUM_COMPLETE on
 SCTP packets
Date: Mon, 07 Aug 2017 14:03:10 -0700 (PDT)
Message-ID: <20170807.140310.1029309060323795084.davem@davemloft.net>
References: <23ac3e005a8dc1a373971f1166fe6ba72d8abe4b.1501793448.git.dcaratti@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tariqt@mellanox.com, netdev@vger.kernel.org
To: dcaratti@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:35980 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751869AbdHGVDL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 7 Aug 2017 17:03:11 -0400
In-Reply-To: <23ac3e005a8dc1a373971f1166fe6ba72d8abe4b.1501793448.git.dcaratti@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Davide Caratti <dcaratti@redhat.com>
Date: Thu,  3 Aug 2017 22:54:48 +0200

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

Can I get reviews from some Mellanox folks please?
