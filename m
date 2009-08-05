From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] net: implement a SO_PROTOCOL getsockoption
Date: Wed, 05 Aug 2009 13:04:05 -0700 (PDT)
Message-ID: <20090805.130405.242822698.davem@davemloft.net>
References: <1249406909-24161-1-git-send-email-jengelh@medozas.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: jengelh@medozas.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45383
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751398AbZHEUD4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Aug 2009 16:03:56 -0400
In-Reply-To: <1249406909-24161-1-git-send-email-jengelh@medozas.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jan Engelhardt <jengelh@medozas.de>
Date: Tue,  4 Aug 2009 19:28:28 +0200

> Similar to SO_TYPE returning the socket type, SO_PROTOCOL allows to
> retrieve the protocol used with a given socket.
> 
> I am not quite sure why we have that-many copies of socket.h, and why
> the values are not the same on all arches either, but for where hex
> numbers dominate, I use 0x1029 for SO_PROTOCOL as that seems to be
> the next free unused number across a bunch of operating systems, or
> so Google results make me want to believe. SO_PROTOCOL for others
> just uses the next free Linux number, 38.
> 
> Signed-off-by: Jan Engelhardt <jengelh@medozas.de>

Applied to net-next-2.6

