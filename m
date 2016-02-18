From: Saeed Mahameed <saeedm@dev.mellanox.co.il>
Subject: Re: [PATCH net-next 04/12] net/mlx5e: Support DCBNL IEEE ETS
Date: Thu, 18 Feb 2016 11:58:53 +0200
Message-ID: <CALzJLG91DmFG_mr9sX4hnxx2pTad=ZMuDVqmrCwDJaxjyVoJRw@mail.gmail.com>
References: <1455653401-9808-1-git-send-email-saeedm@mellanox.com>
	<1455653401-9808-5-git-send-email-saeedm@mellanox.com>
	<CAJ3xEMjbOAyzu_6B23HPJshY+p9Dm23P6Sr2SxA=caHz6iuk6A@mail.gmail.com>
	<CALzJLG_7bkC1nZix_SHD_OmumAm8vC-Bhjj6dD95QzNamLsstA@mail.gmail.com>
	<CAJ3xEMgXhaSE8d5NxcjDdHxzXe=X0eU_71ncxtrZ8EN9SBZoGg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Saeed Mahameed <saeedm@mellanox.com>,
	"David S. Miller" <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Tal Alon <talal@mellanox.com>,
	Eran Ben Elisha <eranbe@mellanox.com>,
	Tariq Toukan <tariqt@mellanox.com>
To: Or Gerlitz <gerlitz.or@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f196.google.com ([209.85.161.196]:35037 "EHLO
	mail-yw0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1425918AbcBRJ7O (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Feb 2016 04:59:14 -0500
Received: by mail-yw0-f196.google.com with SMTP id u200so1461020ywf.2
        for <netdev@vger.kernel.org>; Thu, 18 Feb 2016 01:58:54 -0800 (PST)
In-Reply-To: <CAJ3xEMgXhaSE8d5NxcjDdHxzXe=X0eU_71ncxtrZ8EN9SBZoGg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Feb 17, 2016 at 5:49 PM, Or Gerlitz <gerlitz.or@gmail.com> wrote:
> On Wed, Feb 17, 2016 at 2:07 PM, Saeed Mahameed
> <saeedm@dev.mellanox.co.il> wrote:
>> On Tue, Feb 16, 2016 at 11:38 PM, Or Gerlitz <gerlitz.or@gmail.com> wrote:
>
>>>> -       for (tc = 0; tc < priv->params.num_tc; tc++) {
>>>> +       for (tc = 0; tc < MLX5E_MAX_NUM_TC; tc++) {
>>>>                 err = mlx5e_create_tis(priv, tc);
>
>>> various places in the patch use priv->params.num_tc, wasn't sure if
>>> it's correct to hard code things here, and if it does, why not hard
>>> code everywhere
>
>> TISs and TIRs unlike SQs and RQs are created once on driver load, so
>> we create the MAX supported TISs (TIS per prio)  and when you create
>> the rings/channels (SQs) we create them according to the dynamic
>> "priv->params.num_tc" and then we assign the pre allocated TIS to the
>> SQ according to SQ TC/Prio configuration.
>
> makes sense. Maybe spare few words on that in the change-log, or with
> a small comment
> in the code?

will add to change log.
