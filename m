From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6 v7 05/12] net-caif: add CAIF core protocol
 stack
Date: Mon, 29 Mar 2010 17:11:44 -0700 (PDT)
Message-ID: <20100329.171144.48808141.davem@davemloft.net>
References: <1269900693-9118-4-git-send-email-sjur.brandeland@stericsson.com>
	<1269900693-9118-5-git-send-email-sjur.brandeland@stericsson.com>
	<1269900693-9118-6-git-send-email-sjur.brandeland@stericsson.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, marcel@holtmann.org,
	daniel.martensson@stericsson.com, sjurbr@gmail.com
To: sjur.brandeland@stericsson.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44493
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752751Ab0C3ALm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Mar 2010 20:11:42 -0400
In-Reply-To: <1269900693-9118-6-git-send-email-sjur.brandeland@stericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: sjur.brandeland@stericsson.com
Date: Tue, 30 Mar 2010 00:11:26 +0200

> +struct cflayer *cfctrl_create()
> +{

This needs to be (void) not plain ().

This happens for all of your *_create() functions, please
fix this up.
