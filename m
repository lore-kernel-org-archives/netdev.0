From: Rick Jones <rick.jones2@hpe.com>
Subject: Re: [PATCH net V1 1/6] net/mlx4_en: Count HW buffer overrun only once
Date: Wed, 17 Feb 2016 10:04:34 -0800
Message-ID: <56C4B632.8030700@hpe.com>
References: <1455722667-23179-1-git-send-email-ogerlitz@mellanox.com>
 <1455722667-23179-2-git-send-email-ogerlitz@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Eran Ben Elisha <eranbe@mellanox.com>,
	Yishai Hadas <yishaih@mellanox.com>,
	Amir Vadai <amir@vadai.me>,
	Eugenia Emantayev <eugenia@mellanox.com>
To: Or Gerlitz <ogerlitz@mellanox.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t3426.houston.hp.com ([15.201.208.54]:24340 "EHLO
	g4t3426.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1161024AbcBQSEg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Feb 2016 13:04:36 -0500
In-Reply-To: <1455722667-23179-2-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/17/2016 07:24 AM, Or Gerlitz wrote:
> From: Amir Vadai <amir@vadai.me>
>
> RdropOvflw counts overrun of HW buffer, therefore should
> be used for rx_fifo_errors only.
>
> Currently RdropOvflw counter is mistakenly also set into
> rx_missed_errors and rx_over_errors too, which makes the
> device total dropped packets accounting to show wrong results.
>
> Fix that. Use it for rx_fifo_errors only.
>
> Fixes: c27a02cd94d6 ('mlx4_en: Add driver for Mellanox ConnectX 10GbE NIC')
> Signed-off-by: Amir Vadai <amir@vadai.me>
> Signed-off-by: Eugenia Emantayev <eugenia@mellanox.com>
> Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>

Reviewed-By: Rick Jones <rick.jones2@hpe.com>

rick
