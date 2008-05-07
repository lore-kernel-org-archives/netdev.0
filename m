From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] NET: Remove PACKET_FASTROUTE
Date: Wed, 07 May 2008 02:35:24 -0700 (PDT)
Message-ID: <20080507.023524.193709565.davem@davemloft.net>
References: <4821713E.7050308@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: wangchen@cn.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:32790
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751497AbYEGJfa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 May 2008 05:35:30 -0400
In-Reply-To: <4821713E.7050308@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wang Chen <wangchen@cn.fujitsu.com>
Date: Wed, 07 May 2008 17:07:10 +0800

> Since we do not support fastroute anymore, remove macro PACKET_FASTROUTE.
> 
> Signed-off-by: Wang Chen <wangchen@cn.fujitsu.com>

We should leave it there so that this value is not accidently
allocatod to another purpose.

If you really really want to remove it, at least add a comment
there that value "6" used to be allocated to PACKET_FASTROUTE,
and therefore cannot be reused.

But, to be honest, keeping the define there serves that purpose just
as well.
