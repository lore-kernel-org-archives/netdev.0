From: Lutz Jaenicke <ljaenicke@innominate.com>
Subject: Re: [PATCH 2/2][net-next] gianfar: Add ethtool -A support for pause frame
Date: Fri,  9 Aug 2013 10:26:28 +0200
Message-ID: <1376036790-18238-1-git-send-email-ljaenicke@innominate.com>
References: <1375987549.2853.67.camel@deadeye.wl.decadent.org.uk>
Cc: Claudiu Manoil <claudiu.manoil@freescale.com>,
	Ben Hutchings <bhutchings@solarflare.com>,
	"David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from host2.bln.innominate.com ([77.245.32.75]:51849 "EHLO
	home.innominate.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030535Ab3HII0k (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Aug 2013 04:26:40 -0400
In-Reply-To: <1375987549.2853.67.camel@deadeye.wl.decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I have been working on the same issue and came up with a similar
modification (that additionally implements LFC if supported)
I have attached the two patches created:
* gianfar: implement flow control handling
  which looks quite similar to Claudiu's patches
* gianfar: add support for LFC (Lossless Flow Control)
  which is more or less just extracted from some patch I found on the internet
    linux-2.6.29.6-mpc8308e_rdb.patch
The patches I have taken from a custom 3.4 based kernel so they may not
apply cleanly but maybe bits of it can be used to generate fully supported
solution.
