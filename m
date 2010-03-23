From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] netdev: don't always reset iflink when registering
Date: Mon, 22 Mar 2010 20:20:22 -0700 (PDT)
Message-ID: <20100322.202022.139110361.davem@davemloft.net>
References: <20100320013917.GB13239@boeing.com>
	<4BA7AC13.3080408@trash.net>
	<6AFD35BEDB60334C9A31FD694E13EF0D22676C2244@XCH-NW-18V.nw.nos.boeing.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, netdev@vger.kernel.org
To: Thomas.Goff@boeing.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50459
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752062Ab0CWDT7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Mar 2010 23:19:59 -0400
In-Reply-To: <6AFD35BEDB60334C9A31FD694E13EF0D22676C2244@XCH-NW-18V.nw.nos.boeing.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Goff, Thomas" <Thomas.Goff@boeing.com>
Date: Mon, 22 Mar 2010 12:06:46 -0700

> So maybe it makes more sense to change these if that's more consistent
> with other cases.

Yes, it does.  The canonical place to set ->iflink by hand
is the ->ndo_init() method of the device.
