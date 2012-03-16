From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 4/4] cdc_ncm: remove redundant header files
Date: Fri, 16 Mar 2012 02:08:06 -0700 (PDT)
Message-ID: <20120316.020806.2142585782724456200.davem@davemloft.net>
References: <1331760373-1914-1-git-send-email-alexey.orishko@stericsson.com>
	<1331760373-1914-4-git-send-email-alexey.orishko@stericsson.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, oliver@neukum.org,
	linux-usb@vger.kernel.org, gregkh@linuxfoundation.org,
	alexey.orishko@stericsson.com
To: alexey.orishko@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:36438 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759547Ab2CPJIQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Mar 2012 05:08:16 -0400
In-Reply-To: <1331760373-1914-4-git-send-email-alexey.orishko@stericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexey Orishko <alexey.orishko@gmail.com>
Date: Wed, 14 Mar 2012 22:26:13 +0100

> Signed-off-by: Alexey Orishko <alexey.orishko@stericsson.com>

I'm not applying this.

> -#include <linux/ethtool.h>

This file does very much do use the types in ethtool.h

I have a feeling you weren't very meticulious about this change
and basically said "it compiles, must be good".
