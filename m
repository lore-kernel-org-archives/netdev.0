From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next v4 1/1] net: fec: Enable imx6 enet checksum
 acceleration.
Date: Fri, 19 Apr 2013 08:59:22 -0700
Message-ID: <1366387162.16391.21.camel@edumazet-glaptop>
References: <Jim Baxter <jim_baxter@mentor.com>
	  <1366384215-21441-1-git-send-email-jim_baxter@mentor.com>
	 <1366385398.16391.19.camel@edumazet-glaptop> <517168DB.4050705@mentor.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Fabio Estevam <fabio.estevam@freescale.com>,
	Frank Li <Frank.Li@freescale.com>,
	Fugang Duan <B38611@freescale.com>, netdev@vger.kernel.org,
	Ben Hutchings <bhutchings@solarflare.com>
To: Jim Baxter <jim_baxter@mentor.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-da0-f51.google.com ([209.85.210.51]:55086 "EHLO
	mail-da0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751775Ab3DSP7Y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Apr 2013 11:59:24 -0400
Received: by mail-da0-f51.google.com with SMTP id g27so2013735dan.10
        for <netdev@vger.kernel.org>; Fri, 19 Apr 2013 08:59:24 -0700 (PDT)
In-Reply-To: <517168DB.4050705@mentor.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-04-19 at 16:55 +0100, Jim Baxter wrote:

> 
> I have no issue with changing it, but I am curious, by returning OK will
> the kernel not regard it a sent packet and it will be lost?

Answer is : The sender will loop forever trying to send this packet.
Just drop it and avoid a possible deadlock.

NETDEV_TX_BUSY is deprecated and its use is not for solving this kind of
problem.
