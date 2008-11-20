From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: tulip/de2104x.c replace register macros with
 static inlines
Date: Thu, 20 Nov 2008 02:01:18 -0800 (PST)
Message-ID: <20081120.020118.74510390.davem@davemloft.net>
References: <1227044153.13182.6.camel@brick>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, netdev@vger.kernel.org
To: harvey.harrison@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52240
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753577AbYKTKBS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Nov 2008 05:01:18 -0500
In-Reply-To: <1227044153.13182.6.camel@brick>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Harvey Harrison <harvey.harrison@gmail.com>
Date: Tue, 18 Nov 2008 13:35:53 -0800

> Signed-off-by: Harvey Harrison <harvey.harrison@gmail.com>
> ---
> I noticed this while checking out the sparse warning about do-while not
> being a compound statement, maybe a bit silly, but I had it done, so I'll
> see if you want to apply it.

Not really. :)

This is a common idiom, hiting the device private pointer variable
purely inside of the macro definition.  Probably more than at least 10
drivers do this, and trust me it saves a lot of typing. :)

