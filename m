From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v7 04/11] net/mlx4_en: add support for fast rx drop bpf
 program
Date: Mon, 11 Jul 2016 23:17:00 -0700 (PDT)
Message-ID: <20160711.231700.1668856499968096629.davem@davemloft.net>
References: <1468272598-21390-1-git-send-email-bblanco@plumgrid.com>
	<1468272598-21390-5-git-send-email-bblanco@plumgrid.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jhs@mojatatu.com,
	saeedm@dev.mellanox.co.il, kafai@fb.com, brouer@redhat.com,
	as754m@att.com, alexei.starovoitov@gmail.com, gerlitz.or@gmail.com,
	john.fastabend@gmail.com, hannes@stressinduktion.org,
	tgraf@suug.ch, tom@herbertland.com, daniel@iogearbox.net
To: bblanco@plumgrid.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:37304 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750891AbcGLGRC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Jul 2016 02:17:02 -0400
In-Reply-To: <1468272598-21390-5-git-send-email-bblanco@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Brenden Blanco <bblanco@plumgrid.com>
Date: Mon, 11 Jul 2016 14:29:51 -0700

> +	if (priv->num_frags > 1)
> +		return -EOPNOTSUPP;

I hate to be the user who has to debug why his XDP program won't
load just because he set a jumbo MTU beforehand.
