From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: remove padding from struct socket on 64bit &
 increase objects/cache
Date: Tue, 08 Jul 2008 03:03:33 -0700 (PDT)
Message-ID: <20080708.030333.169790510.davem@davemloft.net>
References: <1215431890.3101.5.camel@castor.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: richard@rsk.demon.co.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36496
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752131AbYGHKDd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Jul 2008 06:03:33 -0400
In-Reply-To: <1215431890.3101.5.camel@castor.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Richard Kennedy <richard@rsk.demon.co.uk>
Date: Mon, 07 Jul 2008 12:58:10 +0100

> remove padding from struct socket reducing its size by 8 bytes.
>     
> This allows more objects/cache in sock_inode_cache
> 12 objects/cache when cacheline size is 128 (generic x86_64)
>     
> Signed-off-by: Richard Kennedy <richard@rsk.demon.co.uk>

Applied to net-next-2.6, thanks!
