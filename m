From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ibmtr: possible Read buffer overflow?
Date: Thu, 29 Oct 2009 22:54:56 -0700 (PDT)
Message-ID: <20091029.225456.91122949.davem@davemloft.net>
References: <4AC7C19F.2080800@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org
To: roel.kluin@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49121
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755791AbZJ3Fyd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Oct 2009 01:54:33 -0400
In-Reply-To: <4AC7C19F.2080800@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roel Kluin <roel.kluin@gmail.com>
Date: Sat, 03 Oct 2009 23:26:55 +0200

> Prevent read outside array bounds.
> 
> Signed-off-by: Roel Kluin <roel.kluin@gmail.com>
> ---
> Is this maybe required?

I can't see anything that protects against this, so yes it
seems to be required.

Applied to net-2.6, thanks.
