From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] b44: strncpy does not null terminate string
Date: Mon, 20 Jul 2009 08:04:00 -0700 (PDT)
Message-ID: <20090720.080400.166455438.davem@davemloft.net>
References: <4A607185.6020302@gmail.com>
	<4A60BC92.7030406@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: zambrano@broadcom.com, netdev@vger.kernel.org,
	akpm@linux-foundation.org
To: roel.kluin@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59051
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752005AbZGTPDz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Jul 2009 11:03:55 -0400
In-Reply-To: <4A60BC92.7030406@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roel Kluin <roel.kluin@gmail.com>
Date: Fri, 17 Jul 2009 20:01:54 +0200

> strlcpy() will always null terminate the string. Also use the
> sizeof(version) to strlcopy() the version string.
> 
> Signed-off-by: Roel Kluin <roel.kluin@gmail.com>

Applied to net-next-2.6
