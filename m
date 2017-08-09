From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v2] net/mlx4_en: don't set CHECKSUM_COMPLETE on
 SCTP packets
Date: Tue, 08 Aug 2017 18:00:31 -0700 (PDT)
Message-ID: <20170808.180031.2176916502629959013.davem@davemloft.net>
References: <23ac3e005a8dc1a373971f1166fe6ba72d8abe4b.1501793448.git.dcaratti@redhat.com>
        <CALzJLG-Xp1TeYQBm6bwOmGxbtzMp0ohmLOY+iMCg1U9QcC791Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dcaratti@redhat.com, tariqt@mellanox.com, netdev@vger.kernel.org
To: saeedm@dev.mellanox.co.il
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:58042 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752192AbdHIBAc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 8 Aug 2017 21:00:32 -0400
In-Reply-To: <CALzJLG-Xp1TeYQBm6bwOmGxbtzMp0ohmLOY+iMCg1U9QcC791Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Saeed Mahameed <saeedm@dev.mellanox.co.il>
Date: Tue, 8 Aug 2017 19:16:52 +0300

> On Thu, Aug 3, 2017 at 11:54 PM, Davide Caratti <dcaratti@redhat.com> wrote:
>> if the NIC fails to validate the checksum on TCP/UDP, and validation of IP
>> checksum is successful, the driver subtracts the pseudo-header checksum
>> from the value obtained by the hardware and sets CHECKSUM_COMPLETE. Don't
>> do that if protocol is IPPROTO_SCTP, otherwise CRC32c validation fails.
>>
>> V2: don't test MLX4_CQE_STATUS_IPV6 if MLX4_CQE_STATUS_IPV4 is set
>>
>> Reported-by: Shuang Li <shuali@redhat.com>
>> Fixes: f8c6455bb04b ("net/mlx4_en: Extend checksum offloading by CHECKSUM COMPLETE")
>> Signed-off-by: Davide Caratti <dcaratti@redhat.com>
> 
> Acked-by: Saeed Mahameed <saeedm@mellanox.com>

Applied and queued up for -stable.
