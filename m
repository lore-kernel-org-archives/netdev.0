From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: Re: [PATCH net 1/2] net/mlx4_en: Fix bridged vSwitch configuration
 for non SRIOV mode
Date: Thu, 17 Jan 2013 18:34:05 +0200
Message-ID: <50F827FD.1070108@mellanox.com>
References: <1358436643-1326-1-git-send-email-ogerlitz@mellanox.com>  <1358436643-1326-2-git-send-email-ogerlitz@mellanox.com> <1358439708.29723.55.camel@edumazet-glaptop> <50F8279F.5030403@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<amirv@mellanox.com>, <jackm@dev.mellanox.co.il>,
	<yevgenyp@mellanox.com>, Yan Burman <yanb@mellanox.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog115.obsmtp.com ([207.126.144.139]:60691 "HELO
	eu1sys200aog115.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1756876Ab3AQQdb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Jan 2013 11:33:31 -0500
In-Reply-To: <50F8279F.5030403@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 17/01/2013 18:32, Or Gerlitz wrote:
> (I don't really understand why mlx4_en_mac_to_u64() is done... its 
> horribly expensive...). matching 6 bytes can be done in 3 x86_64 
> instructions using the right helper (ether_addr_equal_64bits()) 

thanks for the heads up, we will fix.

Or.
