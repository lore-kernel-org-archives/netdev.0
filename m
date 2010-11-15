From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-26 5/5] cxgb4vf: Mark "UDP [RSS Hash] Enable"
 as a 1-bit field.
Date: Mon, 15 Nov 2010 09:20:59 -0800 (PST)
Message-ID: <20101115.092059.59691885.davem@davemloft.net>
References: <1289503844-18059-1-git-send-email-leedom@chelsio.com>
	<1289503844-18059-6-git-send-email-leedom@chelsio.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: leedom@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47862
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757516Ab0KORUe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Nov 2010 12:20:34 -0500
In-Reply-To: <1289503844-18059-6-git-send-email-leedom@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Casey Leedom <leedom@chelsio.com>
Date: Thu, 11 Nov 2010 11:30:44 -0800

> +		uint synmapen:1;	/* SYN Map Enable */

Please do not use the "uint" shorthand for "unsigned int", I know it's
in linux/types.h but that is there for sysv compatibility in
userspace and is ugly as hell.
