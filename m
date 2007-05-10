From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] phylib: phy_ethtool_{sset,gset} -- check phydev for NULL
Date: Thu, 10 May 2007 14:19:01 -0400
Message-ID: <46436215.7030503@garzik.org>
References: <8496f91a0705101029g794ee4a7t1c6a34ad13444c49@mail.gmail.com> <20070510105613.f564e083.randy.dunlap@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: matvejchikov@gmail.com, netdev@vger.kernel.org
To: Randy Dunlap <randy.dunlap@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:58526 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753144AbXEJSTE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 May 2007 14:19:04 -0400
In-Reply-To: <20070510105613.f564e083.randy.dunlap@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Randy Dunlap wrote:
> and I hope that Jeff prefers (as some others do):
> 
> 	if (unlikely(phydev == NULL))
> 
> or even
> 
> 	if (unlikely(!phydev))


That is indeed my preference :)

	Jeff


