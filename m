From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] phylib: unsigneds go unnoticed
Date: Sun, 18 Jan 2009 21:25:12 -0800 (PST)
Message-ID: <20090118.212512.149560148.davem@davemloft.net>
References: <4973B3E7.6080203@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: paulius.zaleckas@teltonika.lt, netdev@vger.kernel.org
To: roel.kluin@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53339
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751415AbZASFZL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Jan 2009 00:25:11 -0500
In-Reply-To: <4973B3E7.6080203@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roel Kluin <roel.kluin@gmail.com>
Date: Sun, 18 Jan 2009 23:57:43 +0100

> both pdata->mdc and pdata->mdio are unsigned. Notice a negative
> return value.

You left the unsigned tests in there:

>  	if (pdata->mdc < 0 || pdata->mdio < 0)
>  		goto out_free;

Please remove them.
