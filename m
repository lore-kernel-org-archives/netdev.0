From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 5/8] net/mlx4_en: Remove redundant code from
 RX/GRO path
Date: Thu, 30 Oct 2014 12:00:31 -0700
Message-ID: <1414695631.15352.5.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1414685216-28907-1-git-send-email-ogerlitz@mellanox.com>
	 <1414685216-28907-6-git-send-email-ogerlitz@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Matan Barak <matanb@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>,
	Shani Michaeli <shanim@mellanox.com>
To: Or Gerlitz <ogerlitz@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:64306 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752318AbaJ3TAc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Oct 2014 15:00:32 -0400
Received: by mail-pa0-f50.google.com with SMTP id eu11so5994921pac.23
        for <netdev@vger.kernel.org>; Thu, 30 Oct 2014 12:00:32 -0700 (PDT)
In-Reply-To: <1414685216-28907-6-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2014-10-30 at 18:06 +0200, Or Gerlitz wrote:
> Remove the code which goes through napi_gro_frags() on the RX path,
> use only napi_gro_receive().
> 
> Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
> ---

Hmpff... napi_gro_frags() should be faster.

Have you benchmarked this ?
