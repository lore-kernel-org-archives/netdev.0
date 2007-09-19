From: David Miller <davem@davemloft.net>
Subject: Re: net-2.6.24 - build failure
Date: Wed, 19 Sep 2007 15:17:12 -0700 (PDT)
Message-ID: <20070919.151712.66176476.davem@davemloft.net>
References: <1190238802.26101.24.camel@localhost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-wireless@vger.kernel.org
To: joe@perches.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47990
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750717AbXISWRN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Sep 2007 18:17:13 -0400
In-Reply-To: <1190238802.26101.24.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Joe Perches <joe@perches.com>
Date: Wed, 19 Sep 2007 14:53:22 -0700

> drivers/net/wireless/b43legacy/built-in.o: In function `tsf_read_file':
> drivers/net/wireless/b43legacy/debugfs.c:80: multiple definition of `tsf_read_file'

Can one of the wireless folks fix b43legacy to not use the same
global variable and function names as the b43 driver?

Thanks.
