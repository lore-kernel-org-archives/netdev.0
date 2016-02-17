From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: Re: [PATCH net 1/6] net/mlx4_en: Do not count dropped packets twice
Date: Wed, 17 Feb 2016 12:19:48 +0200
Message-ID: <56C44944.20803@mellanox.com>
References: <1455634911-31206-1-git-send-email-ogerlitz@mellanox.com>
 <1455634911-31206-2-git-send-email-ogerlitz@mellanox.com>
 <56C36B1D.3050007@hpe.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, Eran Ben Elisha <eranbe@mellanox.com>,
	"Yishai Hadas" <yishaih@mellanox.com>, Amir Vadai <amir@vadai.me>,
	Eugenia Emantayev <eugenia@mellanox.com>
To: Rick Jones <rick.jones2@hpe.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-am1on0097.outbound.protection.outlook.com ([157.56.112.97]:36620
	"EHLO emea01-am1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S965210AbcBQKUB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Feb 2016 05:20:01 -0500
In-Reply-To: <56C36B1D.3050007@hpe.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2/16/2016 8:31 PM, Rick Jones wrote:
>
> I'm still not clear on when an Acked-by is appropriate, but given that 
> this has been a non-trivial frustration for a long time, a hearty 
> endorsement from me.  Perhaps not important enough but it would be 
> nice to have it flow back a release or two.

sure, will ask stable inclusion as well

>
> That said, should mlx4_en_stats->RdropOvflw still be going into both 
> rx_fifo_errors and rx_over_errors?
>
>         stats->rx_over_errors = be32_to_cpu(mlx4_en_stats->RdropOvflw);
>         stats->rx_crc_errors = be32_to_cpu(mlx4_en_stats->RCRC);
>         stats->rx_frame_errors = 0;
>         stats->rx_fifo_errors = be32_to_cpu(mlx4_en_stats->RdropOvflw);

yep, point taken, we will leave it only for the over ones, thanks for 
pointing this out


Or.
