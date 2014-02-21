From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH net-next V2 1/2] net/mlx4: Set number of RX rings in a
 utility function
Date: Fri, 21 Feb 2014 11:01:17 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D0F6C800B@AcuExch.aculab.com>
References: <1392979158-18093-1-git-send-email-amirv@mellanox.com>
 <1392979158-18093-2-git-send-email-amirv@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: Or Gerlitz <ogerlitz@mellanox.com>,
	Yevgeny Petrilin <yevgenyp@mellanox.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Ido Shamay <idos@mellanox.com>
To: 'Amir Vadai' <amirv@mellanox.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:38403 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1755098AbaBULCF convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Feb 2014 06:02:05 -0500
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 08021-07 for <netdev@vger.kernel.org>;
 Fri, 21 Feb 2014 11:02:01 +0000 (GMT)
In-Reply-To: <1392979158-18093-2-git-send-email-amirv@mellanox.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Amir Vadai
> From: Ido Shamay <idos@mellanox.com>
> 
> mlx4_en_add() is too long.
> Moving set number of RX rings to a utiltity function to improve
> readability and modulization of the code.
...
> --- a/drivers/net/ethernet/mellanox/mlx4/en_rx.c
> +++ b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
> @@ -318,6 +318,28 @@ static void mlx4_en_free_rx_buf(struct mlx4_en_priv *priv,
>  	}
>  }
> 
> +void mlx4_en_set_num_rx_rings(struct mlx4_en_dev *mdev)
> +{

Should be static.

	David
