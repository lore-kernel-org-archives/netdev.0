From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 4/4] net/mlx4_en: get rid of private
 net_device_stats
Date: Thu, 26 May 2016 12:35:41 -0700 (PDT)
Message-ID: <20160526.123541.8425919777831825.davem@davemloft.net>
References: <1464195039-5098-1-git-send-email-edumazet@google.com>
	<1464195039-5098-5-git-send-email-edumazet@google.com>
	<6320ccdc-d369-c08c-c959-6c8ed9b88d10@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: edumazet@google.com, netdev@vger.kernel.org, willemb@google.com,
	eugenia@mellanox.com, eric.dumazet@gmail.com
To: ttoukan.linux@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53799 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754727AbcEZTfn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 May 2016 15:35:43 -0400
In-Reply-To: <6320ccdc-d369-c08c-c959-6c8ed9b88d10@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tariq Toukan <ttoukan.linux@gmail.com>
Date: Thu, 26 May 2016 12:38:58 +0300

> I am aware that clearing the stats structure might be redundant today,
> as the function is called only within mlx4_en_open, but we might want
> to call the function in other flows in the future.

You really should not arbitrarily clear the statistics, a down/up is not
supposed to rest them, for example.
