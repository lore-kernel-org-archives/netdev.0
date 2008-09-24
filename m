From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH 05/11] Phonet: Netlink interface
Date: Wed, 24 Sep 2008 15:23:38 +0200
Message-ID: <20080924132338.GR20815@postel.suug.ch>
References: <200809221845.54736.remi.denis-courmont@nokia.com> <1222098445-26175-5-git-send-email-remi.denis-courmont@nokia.com> <20080923121002.GQ20815@postel.suug.ch> <200809241430.45344.remi.denis-courmont@nokia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: =?iso-8859-1?Q?R=E9mi?= Denis-Courmont
	<remi.denis-courmont@Nokia.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:51284 "EHLO postel.suug.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751528AbYIXNXS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 24 Sep 2008 09:23:18 -0400
Content-Disposition: inline
In-Reply-To: <200809241430.45344.remi.denis-courmont@nokia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

* R?mi Denis-Courmont <remi.denis-courmont@Nokia.com> 2008-09-24 14:30
> Ok, thanks. Would this work?

Yes, looks good.

> +	if (op == RTM_NEWADDR)
> +		err = phonet_address_add(dev, pnaddr);
> +	else
> +		err = phonet_address_del(dev, pnaddr);

You could do if (nlh->nlmsg_type == RTM_NEWADDR) here and register this
functions for both add and delete.
