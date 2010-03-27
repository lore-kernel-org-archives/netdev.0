From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] netlink: use the appropriate namespace pid
Date: Fri, 26 Mar 2010 20:14:26 -0700 (PDT)
Message-ID: <20100326.201426.05866973.davem@davemloft.net>
References: <20100321.213022.22037430.davem@davemloft.net>
	<b6fcc0a1003240058i524c95eere17c1349d14267b1@mail.gmail.com>
	<b6fcc0a1003240119h7c26d649taa1f947c2aeb6064@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: thomas.goff@boeing.com, netdev@vger.kernel.org,
	adobriyan@openvz.org
To: adobriyan@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35332
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751408Ab0C0DOD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Mar 2010 23:14:03 -0400
In-Reply-To: <b6fcc0a1003240119h7c26d649taa1f947c2aeb6064@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexey Dobriyan <adobriyan@gmail.com>
Date: Wed, 24 Mar 2010 10:19:37 +0200

>>> Alexey, can you review Tom's namespace patches in this
>>> set?
> 
> re netns sched patch:
> 
> * in psched_open() PDE(inode)->data isn't needed because
>   it isn't used -- just pass NULL.
> * drop useless trailing return; in psched_net_exit() :^)
> * sch_mirred.c still won't work in netns

Tom, please send a patch to fixup these issues.

Thanks.
