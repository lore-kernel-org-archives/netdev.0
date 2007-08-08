From: Arjan van de Ven <arjan@infradead.org>
Subject: Re: [PATCH] net/tulip/xircom_cb.c: remove superfulous priv
	assignment
Date: Wed, 08 Aug 2007 13:14:46 -0700
Message-ID: <1186604086.7130.0.camel@laptopd505.fenrus.org>
References: <200708081320.26756.m.kozlowski@tuxland.pl>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jgarzik@pobox.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Mariusz Kozlowski <m.kozlowski@tuxland.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:36091 "EHLO
	pentafluge.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760831AbXHHUQ5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Aug 2007 16:16:57 -0400
In-Reply-To: <200708081320.26756.m.kozlowski@tuxland.pl>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2007-08-08 at 13:20 +0200, Mariusz Kozlowski wrote:
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


Looks good

Acked-by: Arjan van de Ven <arjan@linux.intel.com>


-- 
if you want to mail me at work (you don't), use arjan (at) linux.intel.com
Test the interaction between Linux and your BIOS via http://www.linuxfirmwarekit.org

