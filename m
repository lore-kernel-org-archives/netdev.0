From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/4] netns xfrm: xfrm6_tunnel in netns
Date: Thu, 28 Jan 2010 06:35:18 -0800 (PST)
Message-ID: <20100128.063518.11572465.davem@davemloft.net>
References: <20100125203754.GA6145@x200>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, herbert@gondor.apana.org.au
To: adobriyan@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36299
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752863Ab0A1OfF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Jan 2010 09:35:05 -0500
In-Reply-To: <20100125203754.GA6145@x200>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexey Dobriyan <adobriyan@gmail.com>
Date: Mon, 25 Jan 2010 22:37:54 +0200

> I'm not sure about rcu stuff near kmem cache destruction:
> * checks for non-empty hashes look bogus, they're done _before_
>   rcu_berrier()
> * unregistering netns ops is done before kmem_cache destoy
>   (as it should), and unregistering involves rcu barriers by itself
> 
> So it looks nothing should be done.
> 
> Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>

Applied.
