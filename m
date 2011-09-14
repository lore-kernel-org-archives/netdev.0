From: Pekka Riikonen <priikone@iki.fi>
Subject: IFF_TX_SKB_SHARING
Date: Wed, 14 Sep 2011 12:38:42 +0200 (CEST)
Message-ID: <Pine.NEB.4.64.1109141227580.19629@otaku.Xtrmntr.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: nhorman@tuxdriver.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from sauna.silcnet.org ([147.175.66.205]:64745 "EHLO
	otaku.Xtrmntr.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756385Ab1INKvy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Sep 2011 06:51:54 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


The IFF_TX_SKB_SHARING flag was introduced in d88733150.  Was it intended 
that it clears IFF_XMIT_DST_RELEASE flag?  It's set in alloc_netdev_mqs 
but gets cleared by ether_setup (via alloc_etherdev_mqs).

Thanks,

 	Pekka
