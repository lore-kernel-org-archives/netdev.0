From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] bonding: remove unused macro "pr_fmt""
Date: Mon, 21 Jun 2010 13:38:06 -0700 (PDT)
Message-ID: <20100621.133806.226761715.davem@davemloft.net>
References: <20100621193405.GG2656@psychotron.bos.redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: jpirko@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38052
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752183Ab0FUUhz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jun 2010 16:37:55 -0400
In-Reply-To: <20100621193405.GG2656@psychotron.bos.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jpirko@redhat.com>
Date: Mon, 21 Jun 2010 21:34:06 +0200

> Signed-off-by: Jiri Pirko <jpirko@redhat.com>
...
> -#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
> -

Jiri, it is used by every single pr_*() logging call made
in this file.

I was hoping that this facilty and the voluminous amounty of pervasive
usage of this in the networking drivers nowadays would make it
familiar to active hackers like you :-)
