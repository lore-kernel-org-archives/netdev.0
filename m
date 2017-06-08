From: Or Gerlitz <gerlitz.or@gmail.com>
Subject: Re: [PATCH RFC net-next 3/4] net/mlx5: Separate between eswitch and
 MPFS l2 table logic
Date: Thu, 8 Jun 2017 14:12:08 +0300
Message-ID: <CAJ3xEMjaCG-VMdvmVAVCnYoiNp1bBHotyrefhfcgG0Ortqx3gQ@mail.gmail.com>
References: <20170607234214.24723-1-saeedm@mellanox.com> <20170607234214.24723-4-saeedm@mellanox.com>
 <CAJ3xEMi9+iaa3CCA-gdBC7Okz3KgpWbea-vvfYEJFpTQkboxUA@mail.gmail.com> <CALzJLG-wha9D0Ybnu3mAPB8RaDYnfidj2dz81rmdiJzRjw7yCw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Saeed Mahameed <saeedm@mellanox.com>,
        Linux Netdev List <netdev@vger.kernel.org>,
        Jes Sorensen <jsorensen@fb.com>,
        Kernel Team <kernel-team@fb.com>,
        Or Gerlitz <ogerlitz@mellanox.com>
To: Saeed Mahameed <saeedm@dev.mellanox.co.il>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ot0-f179.google.com ([74.125.82.179]:34709 "EHLO
        mail-ot0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750788AbdFHLMJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 8 Jun 2017 07:12:09 -0400
Received: by mail-ot0-f179.google.com with SMTP id t31so21493056ota.1
        for <netdev@vger.kernel.org>; Thu, 08 Jun 2017 04:12:09 -0700 (PDT)
In-Reply-To: <CALzJLG-wha9D0Ybnu3mAPB8RaDYnfidj2dz81rmdiJzRjw7yCw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jun 8, 2017 at 1:26 PM, Saeed Mahameed
<saeedm@dev.mellanox.co.il> wrote:
> On Thu, Jun 8, 2017 at 12:13 PM, Or Gerlitz <gerlitz.or@gmail.com> wrote:


>>> +int mlx5_mpfs_add_mac(struct mlx5_core_dev *dev, u8 *mac)
>>> +{
>>
>>> +       if (!MLX5_VPORT_MANAGER(dev))
>>> +               return 0;
>>> +
>>> +       if (is_multicast_ether_addr(mac))
>>> +               return 0;

>> It would have been much better reviewed and maintained if we can code
>> things in a manner under which we don't get here if not appropriate and
>> not simulate successful return.

> Sure, will consider that, i just wanted to avoid ugly indentations in
> mlx5e set_rx_mode en_fs.c

I understand your concern re ugly indentations, but hopefully we can avoid them
