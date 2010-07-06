From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/4] phylib: preserve ifreq parameter when calling
 generic phy_mii_ioctl()
Date: Mon, 05 Jul 2010 19:03:14 -0700 (PDT)
Message-ID: <20100705.190314.246518903.davem@davemloft.net>
References: <cover.1278307573.git.richard.cochran@omicron.at>
	<3187f4618ad376027868b372df3c22c4c26ec3ec.1278307573.git.richard.cochran@omicron.at>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: richardcochran@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48220
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755877Ab0GFCDA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Jul 2010 22:03:00 -0400
In-Reply-To: <3187f4618ad376027868b372df3c22c4c26ec3ec.1278307573.git.richard.cochran@omicron.at>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Richard Cochran <richardcochran@gmail.com>
Date: Mon, 5 Jul 2010 07:33:03 +0200

> The phy_mii_ioctl() function unnecessarily throws away the original ifreq.
> We need access to the ifreq in order to support PHYs that can perform
> hardware time stamping.
> 
> Two maverick drivers filter the ioctl commands passed to phy_mii_ioctl().
> This is unnecessary since phylib will check the command in any case.
> 
> Signed-off-by: Richard Cochran <richard.cochran@omicron.at>

Applied.
