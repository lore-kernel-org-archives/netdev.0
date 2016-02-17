From: Or Gerlitz <gerlitz.or@gmail.com>
Subject: Re: [PATCH net-next 04/12] net/mlx5e: Support DCBNL IEEE ETS
Date: Wed, 17 Feb 2016 17:49:29 +0200
Message-ID: <CAJ3xEMgXhaSE8d5NxcjDdHxzXe=X0eU_71ncxtrZ8EN9SBZoGg@mail.gmail.com>
References: <1455653401-9808-1-git-send-email-saeedm@mellanox.com>
	<1455653401-9808-5-git-send-email-saeedm@mellanox.com>
	<CAJ3xEMjbOAyzu_6B23HPJshY+p9Dm23P6Sr2SxA=caHz6iuk6A@mail.gmail.com>
	<CALzJLG_7bkC1nZix_SHD_OmumAm8vC-Bhjj6dD95QzNamLsstA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Saeed Mahameed <saeedm@mellanox.com>,
	"David S. Miller" <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Tal Alon <talal@mellanox.com>,
	Eran Ben Elisha <eranbe@mellanox.com>,
	Tariq Toukan <tariqt@mellanox.com>
To: Saeed Mahameed <saeedm@dev.mellanox.co.il>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f174.google.com ([209.85.223.174]:36546 "EHLO
	mail-io0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1161721AbcBQPt3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Feb 2016 10:49:29 -0500
Received: by mail-io0-f174.google.com with SMTP id l127so40811906iof.3
        for <netdev@vger.kernel.org>; Wed, 17 Feb 2016 07:49:29 -0800 (PST)
In-Reply-To: <CALzJLG_7bkC1nZix_SHD_OmumAm8vC-Bhjj6dD95QzNamLsstA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Feb 17, 2016 at 2:07 PM, Saeed Mahameed
<saeedm@dev.mellanox.co.il> wrote:
> On Tue, Feb 16, 2016 at 11:38 PM, Or Gerlitz <gerlitz.or@gmail.com> wrote:

>>> -       for (tc = 0; tc < priv->params.num_tc; tc++) {
>>> +       for (tc = 0; tc < MLX5E_MAX_NUM_TC; tc++) {
>>>                 err = mlx5e_create_tis(priv, tc);

>> various places in the patch use priv->params.num_tc, wasn't sure if
>> it's correct to hard code things here, and if it does, why not hard
>> code everywhere

> TISs and TIRs unlike SQs and RQs are created once on driver load, so
> we create the MAX supported TISs (TIS per prio)  and when you create
> the rings/channels (SQs) we create them according to the dynamic
> "priv->params.num_tc" and then we assign the pre allocated TIS to the
> SQ according to SQ TC/Prio configuration.

makes sense. Maybe spare few words on that in the change-log, or with
a small comment
in the code?
