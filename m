From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2 net-next 0/6] bnx2x: new features patch series
Date: Thu, 26 Dec 2013 11:13:47 -0800
Message-ID: <1388085227.12212.19.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1388044632-9172-1-git-send-email-yuvalmin@broadcom.com>
	 <20131226.133853.2211726123097632477.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: yuvalmin@broadcom.com, netdev@vger.kernel.org, ariele@broadcom.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f43.google.com ([209.85.160.43]:50354 "EHLO
	mail-pb0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753651Ab3LZTNx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Dec 2013 14:13:53 -0500
Received: by mail-pb0-f43.google.com with SMTP id rq2so8447066pbb.16
        for <netdev@vger.kernel.org>; Thu, 26 Dec 2013 11:13:53 -0800 (PST)
In-Reply-To: <20131226.133853.2211726123097632477.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-12-26 at 13:38 -0500, David Miller wrote:
> From: Yuval Mintz <yuvalmin@broadcom.com>
> Date: Thu, 26 Dec 2013 09:57:06 +0200
> 
> > This patch series adds/fixes several new features in the bnx2x driver -
> > it adds support for loading the bnx2x over an UNDI running on a Multi-function
> > device, adds missing bits for PCIe AER support and enables VFs to properly
> > configure multicast filters
> > (In addition, it also contains some small improvements in driver behaviour).
> > 
> > Please consider applying these patches to `net-next'.
> > 
> > Changes from previous versions
> > ------------------------------
> >   v2:
> >      - Fixed comment typo in patch 4 (propogate --> propagate)
> 
> Applied, thanks.

Quick note :

drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c: In function 'bnx2x_drv_info_ether_stat':
drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c:3302:46: error: dereferencing pointer to incomplete type
make[6]: *** [drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.o] Error 1
