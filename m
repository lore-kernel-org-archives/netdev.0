From: Souptick Joarder <jrdr.linux@gmail.com>
Subject: Re: [PATCH] ethernet :mellanox :mlx4: Replace pci_pool_alloc by pci_pool_zalloc
Date: Tue, 29 Nov 2016 12:19:46 +0530
Message-ID: <CAFqt6zbkyquX73bPgm0dTmq-_8cAC0O8yKS0r4+s0PR1AGZ57w@mail.gmail.com>
References: <20161128132819.GA500@gnr743-HP-ZBook-15> <a1b6f877-c40b-656d-2278-d32af1a93bc7@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: yishaih@mellanox.com, netdev@vger.kernel.org,
        linux-rdma@vger.kernel.org,
        Rameshwar Sahu <sahu.rameshwar73@gmail.com>
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f195.google.com ([209.85.223.195]:35693 "EHLO
        mail-io0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753566AbcK2Gts (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 29 Nov 2016 01:49:48 -0500
In-Reply-To: <a1b6f877-c40b-656d-2278-d32af1a93bc7@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 29, 2016 at 12:36 AM, Sergei Shtylyov
<sergei.shtylyov@cogentembedded.com> wrote:
> Hello.
>
> On 11/28/2016 04:28 PM, Souptick Joarder wrote:
>
>> In mlx4_alloc_cmd_mailbox(), pci_pool_alloc() followed by memset will be
>> replaced by pci_pool_zalloc()
>>
>> Signed-off-by: Souptick joarder <jrdr.linux@gmail.com>
>> ---
>>  drivers/net/ethernet/mellanox/mlx4/cmd.c | 3 +--
>>  1 file changed, 1 insertion(+), 2 deletions(-)
>>
>> diff --git a/drivers/net/ethernet/mellanox/mlx4/cmd.c
>> b/drivers/net/ethernet/mellanox/mlx4/cmd.c
>> index e36bebc..ee3bd76 100644
>> --- a/drivers/net/ethernet/mellanox/mlx4/cmd.c
>> +++ b/drivers/net/ethernet/mellanox/mlx4/cmd.c
>> @@ -2679,14 +2679,13 @@ struct mlx4_cmd_mailbox
>> *mlx4_alloc_cmd_mailbox(struct mlx4_dev *dev)
>>         if (!mailbox)
>>                 return ERR_PTR(-ENOMEM);
>>
>> -       mailbox->buf = pci_pool_alloc(mlx4_priv(dev)->cmd.pool,
>> GFP_KERNEL,
>> +       mailbox->buf = pci_pool_zalloc(mlx4_priv(dev)->cmd.pool,
>> GFP_KERNEL,
>>                                       &mailbox->dma);
>
>
>    You need to realign he continuation line now, the way it was aligned in
> the original code.
>

Ok, I will do that.





>
> MBR, Sergei
>
