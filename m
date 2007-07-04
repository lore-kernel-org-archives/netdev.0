From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: Who's allowed to set a skb destructor?
Date: Wed, 4 Jul 2007 13:38:11 +0400
Message-ID: <20070704093811.GE15210@2ka.mipt.ru>
References: <468B54A6.5090902@ens-lyon.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: netdev@vger.kernel.org
To: Brice Goglin <Brice.Goglin@ens-lyon.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:36485 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756907AbXGDJiS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 Jul 2007 05:38:18 -0400
Content-Disposition: inline
In-Reply-To: <468B54A6.5090902@ens-lyon.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jul 04, 2007 at 10:04:54AM +0200, Brice Goglin (Brice.Goglin@ens-lyon.org) wrote:
> So, I'd like to have a clear statement about who's allowed to use a
> destructor :)

That one who allocates skb - if it is socket layer, it sets own
socket destructor, netlink has own too and so on.

> Thanks,
> Brice

-- 
	Evgeniy Polyakov
