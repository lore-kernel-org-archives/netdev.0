From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH] net/tulip/xircom_cb.c: remove superfulous priv assignment
Date: Tue, 14 Aug 2007 01:05:38 -0400
Message-ID: <46C13822.7040803@pobox.com>
References: <200708081320.26756.m.kozlowski@tuxland.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Arjan van de Ven <arjan@infradead.org>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Mariusz Kozlowski <m.kozlowski@tuxland.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:36177 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1765298AbXHNFFn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 14 Aug 2007 01:05:43 -0400
In-Reply-To: <200708081320.26756.m.kozlowski@tuxland.pl>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Mariusz Kozlowski wrote:
> Hello,
> 
> 	Unpatched version does sth like this:
> 
> dev = alloc_etherdev(...
> private = netdev_priv(dev);
> ...
> dev->priv = private;
> 
> which doesn't make much sense (does it?) because this is done in
> alloc_netdev() already.
> 
> struct net_device *alloc_netdev(...
> {
> ...
> 	if (sizeof_priv)
> 		dev->priv = netdev_priv(dev);
> 
> This patch removes superfluous code.
> 
> Signed-off-by: Mariusz Kozlowski <m.kozlowski@tuxland.pl>

applied


