From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6 6/6] be2net: fix unnecessary access to
 hardware to get link, port info
Date: Wed, 02 Dec 2009 01:11:33 -0800 (PST)
Message-ID: <20091202.011133.62636808.davem@davemloft.net>
References: <20091130035736.GA15579@serverengines.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ajitk@serverengines.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57218
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755054AbZLBJL0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Dec 2009 04:11:26 -0500
In-Reply-To: <20091130035736.GA15579@serverengines.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ajit Khaparde <ajitk@serverengines.com>
Date: Mon, 30 Nov 2009 09:27:46 +0530

> Every time while doing ethtool->get_settings we are accessing
> the hardware to get link status and port information.
> This is not necessary.  We now use the cached copy for this info
> and update it when the link status changes.
> 
> From: Suresh R <sureshr@serverengines.com>
> 
> Signed-off-by: Ajit Khaparde <ajitk@serverengines.com>

Applied.
