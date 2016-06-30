From: Saeed Mahameed <saeedm@dev.mellanox.co.il>
Subject: Re: [PATCH net 08/13] net/mlx5e: Implement ndo_tx_timeout callback
Date: Thu, 30 Jun 2016 18:27:05 +0300
Message-ID: <CALzJLG8Jer+iz86SiXPsQC904hcOQnD4bZtDsn7riE64m3etVQ@mail.gmail.com>
References: <1467297290-11443-1-git-send-email-saeedm@mellanox.com>
 <1467297290-11443-9-git-send-email-saeedm@mellanox.com> <CO2PR11MB00884EE7E853CF8FEC58C4D897240@CO2PR11MB0088.namprd11.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Saeed Mahameed <saeedm@mellanox.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Daniel Jurgens <danielj@mellanox.com>
To: Yuval Mintz <Yuval.Mintz@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f177.google.com ([209.85.220.177]:34200 "EHLO
	mail-qk0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932196AbcF3P1h (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Jun 2016 11:27:37 -0400
Received: by mail-qk0-f177.google.com with SMTP id t127so151295720qkf.1
        for <netdev@vger.kernel.org>; Thu, 30 Jun 2016 08:27:24 -0700 (PDT)
In-Reply-To: <CO2PR11MB00884EE7E853CF8FEC58C4D897240@CO2PR11MB0088.namprd11.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jun 30, 2016 at 6:15 PM, Yuval Mintz <Yuval.Mintz@qlogic.com> wrote:
>> Add callback to handle TX timeouts.
>>
>> Fixes: f62b8bb8f2d3 ('net/mlx5: Extend mlx5_core to support ConnectX-4 Ethernet functionality')
>
> Not that I mind, but does implementing ndo_tx_timeout actually counts as a fix?

Why not if you want it to get backported to -stable and distros as a
resiliency fix.

Maybe Dave can give some insight..
