From: Amir Vadai <amirv@mellanox.com>
Subject: Re: [PATCH net-next V1 10/11] net/mlx4_en: Fix Supported/Advertised
 link mode reported by ethtool
Date: Thu, 19 Dec 2013 10:34:37 +0200
Message-ID: <52B2AF9D.3070006@mellanox.com>
References: <1387263720-31222-1-git-send-email-amirv@mellanox.com>	 <1387263720-31222-11-git-send-email-amirv@mellanox.com> <1387295214.1799.63.camel@bwh-desktop.uk.level5networks.com> <52B08B71.90006@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Or Gerlitz <ogerlitz@mellanox.com>,
	Yevgeny Petrilin <yevgenyp@mellanox.com>,
	<netdev@vger.kernel.org>, Rana Shahout <ranas@mellanox.com>,
	Eugenia Emantayev <eugenia@mellanox.co.il>,
	Eyal Perry <eyalpe@mellanox.com>
To: Ben Hutchings <bhutchings@solarflare.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog115.obsmtp.com ([207.126.144.139]:51182 "EHLO
	eu1sys200aog115.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750954Ab3LSIfH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Dec 2013 03:35:07 -0500
In-Reply-To: <52B08B71.90006@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 17/12/2013 19:35, Amir Vadai wrote:
> On 17/12/2013 17:46, Ben Hutchings wrote:
>>> +		ADVERTISED_40000baseLR4_Full;
>> [...]
>>
>> How is this correct?  You should report the actual capabilities of the
>> MAC and PHY are present, not the union of all possible modes of all the
>> supported boards.
> I miss-understood this field.
> Will fix it.
> 
>>
>> (And the Kconfig description for MLX4_EN says '10Gbit Ethernet support',
>> so if this driver now supports some 40G boards that should be updated.)
> Will fix it for V2
> 
>>
>> Ben
> 
> 
> Thanks,
> Amir
> 

Hi Dave,

It seems that we need to write this patch from scratch, so I would like
to remove it from the patchset. So other patches we have in the pipe
won't be delayed.

Regarding the Kconfig description that Ben suggested, I will send it in
the next patchset.

Do you want me to send a V2 with the only difference is this patch
removed, or can you take this set?

Thanks,
Amir
