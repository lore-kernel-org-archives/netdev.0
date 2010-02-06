From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Subject: RE: [PATCH 14/23 v3] mlx4_core: Determine primary physical function
Date: Sat, 6 Feb 2010 08:26:33 +0200
Message-ID: <E113D394D7C5DB4F8FF691FA7EE9DB44388066F0D2@MTLMAIL.mtl.com>
References: <49BFC313.1030901@mellanox.co.il>
	<4B6AEE1F.5050506@mellanox.co.il> <ada3a1gfxbi.fsf@roland-alpha.cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "general@lists.openfabrics.org" <general@lists.openfabrics.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Liran Liss <liranl@mellanox.co.il>,
	Tziporet Koren <tziporet@mellanox.co.il>
To: Roland Dreier <rdreier@cisco.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.mellanox.co.il ([194.90.237.43]:46995 "EHLO mellanox.co.il"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751522Ab0BFGZW convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 6 Feb 2010 01:25:22 -0500
In-Reply-To: <ada3a1gfxbi.fsf@roland-alpha.cisco.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 

>> +	MLX4_FLAG_PF		= 1 << 5,
>
> Am I mistaken, or is this the only place this flag appears anywhere in the patch set?  In other words it is never set and never tested -- so probably we > don't need it?

That is correct

>> +	dev_cap->pf_num = field;
>> +	if (dev_cap->pf_num > 1)
>> +		dev->flags |= MLX4_FLAG_MASTER;
>
> Is this correct?  All PFs > 1 are masters?  Or should the test be "== 1"
> rather than "> 1" instead?

No, It means that if some function get notified that there are more then 1 physical functions on the device, it should act as master.

Thanks,
Yevgeny