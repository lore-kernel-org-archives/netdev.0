From: Saeed Mahameed <saeedm@dev.mellanox.co.il>
Subject: Re: [PATCH net-next 04/12] net/mlx5e: Support DCBNL IEEE ETS
Date: Thu, 18 Feb 2016 11:58:29 +0200
Message-ID: <CALzJLG84dw_N=75ED0yf9EGO3hSPgfSJB53UMATQ298ztv6vxg@mail.gmail.com>
References: <1455653401-9808-1-git-send-email-saeedm@mellanox.com>
	<1455653401-9808-5-git-send-email-saeedm@mellanox.com>
	<CAJ3xEMhxezhiU4XjVZuaDbvZ=0D-HLZYnm8DORLDSg_xquT3Yw@mail.gmail.com>
	<CALzJLG-nbmz292duYuDrU8WUTNi90KAtC+d04Xes8cW+oXXoJQ@mail.gmail.com>
	<CAJ3xEMh2tcOXrbWT7qMx=yVLPSnrFy=68EuhZGS7FBLwqgHVaA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Saeed Mahameed <saeedm@mellanox.com>,
	"David S. Miller" <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Tal Alon <talal@mellanox.com>,
	Eran Ben Elisha <eranbe@mellanox.com>,
	Tariq Toukan <tariqt@mellanox.com>,
	Rana Shahout <ranas@mellanox.com>
To: Or Gerlitz <gerlitz.or@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f194.google.com ([209.85.161.194]:36777 "EHLO
	mail-yw0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1425942AbcBRJ6a (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Feb 2016 04:58:30 -0500
Received: by mail-yw0-f194.google.com with SMTP id h80so1459008ywc.3
        for <netdev@vger.kernel.org>; Thu, 18 Feb 2016 01:58:30 -0800 (PST)
In-Reply-To: <CAJ3xEMh2tcOXrbWT7qMx=yVLPSnrFy=68EuhZGS7FBLwqgHVaA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Feb 17, 2016 at 5:48 PM, Or Gerlitz <gerlitz.or@gmail.com> wrote:
> On Wed, Feb 17, 2016 at 2:00 PM, Saeed Mahameed
> <saeedm@dev.mellanox.co.il> wrote:
>>>>  struct mlx5e_priv {
>>>>         /* priv data path fields - start */
>>>> -       int                        default_vlan_prio;
>>>>         struct mlx5e_sq            **txq_to_sq_map;
>>>>         int channeltc_to_txq_map[MLX5E_MAX_NUM_CHANNELS][MLX5E_MAX_NUM_TC];
>>>>         /* priv data path fields - end */
>>>
>>>
>>> Didn't see a note on the removal of the default vlan prio in the
>>> change-log, could you elaborate what was the role of it before the
>>> patch and why we can just throw it?
>>>
>> it did nothing other than holding the number "0" which is always the
>> default prio for vlans
>> it was replaced with a the real 0 (the hardcoded "0") in the following lines:
>
> okay, I would spare a sentence on that removal in the change, just in
> case someone lands
> here in future bisections and wonders why we removed this.
will add to change log.
