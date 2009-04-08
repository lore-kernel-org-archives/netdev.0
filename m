From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH -next] ethoc: fix library build errors
Date: Wed, 08 Apr 2009 15:41:37 -0700 (PDT)
Message-ID: <20090408.154137.54486472.davem@davemloft.net>
References: <20090408100039.855ab138.randy.dunlap@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, thierry.reding@avionic-design.de
To: randy.dunlap@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53080
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753244AbZDHWlr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Apr 2009 18:41:47 -0400
In-Reply-To: <20090408100039.855ab138.randy.dunlap@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Randy Dunlap <randy.dunlap@oracle.com>
Date: Wed, 8 Apr 2009 10:00:39 -0700

> ethoc indirectly uses crc32_le() and bitrev32(), so select
> those library functions to be built.
> 
> drivers/built-in.o: In function `ethoc_set_multicast_list':
> ethoc.c:(.text+0x6226f): undefined reference to `crc32_le'
> ethoc.c:(.text+0x62276): undefined reference to `bitrev32'
> 
> Signed-off-by: Randy Dunlap <randy.dunlap@oracle.com>


Applied, thanks.
