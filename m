From: David Miller <davem@davemloft.net>
Subject: Re: clarify code intent
Date: Thu, 18 Sep 2008 16:36:33 -0700 (PDT)
Message-ID: <20080918.163633.223533656.davem@davemloft.net>
References: <1221757668.23007.12.camel@ns-test>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: mathieu.lacage@sophia.inria.fr
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34969
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753368AbYIRXgp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Sep 2008 19:36:45 -0400
In-Reply-To: <1221757668.23007.12.camel@ns-test>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mathieu Lacage <mathieu.lacage@sophia.inria.fr>
Date: Thu, 18 Sep 2008 10:07:48 -0700

> The attached patch hopefully clarifies the intent of the unix_bind
> function in net/unix/af_unix.c.

I've rejected this patch over and over in the past, and nothing
has happened to change my mind since then.

----------------------------------------
Subject: Re: [PATCH,TRIVIAL] AF_UNIX, accept() and addrlen
From: David Miller <davem@davemloft.net>
To: samuel.thibault@ens-lyon.org
Cc: mtk.manpages@gmail.com, mtk.manpages@googlemail.com,
 andi@firstfloor.org, linux-kernel@vger.kernel.org
Date: Sat, 26 Apr 2008 22:54:32 -0700 (PDT)
X-Mailer: Mew version 5.2 on Emacs 22.1 / Mule 5.0 (SAKAKI)

From: Samuel Thibault <samuel.thibault@ens-lyon.org>
Date: Sat, 26 Apr 2008 02:44:45 +0100

> AF_UNIX: make unix_getname use sizeof(sunaddr->sun_family) instead of
> sizeof(short).
> 
> Signed-off-by: Samuel Thibault <samuel.thibault@ens-lyon.org>

This is just syntactic masterbation, sa_family_t is typedef'd
"unsigned short".

No system on planet earth providing the BSD sockets API uses
anything other than uint16_t or unsigned short for this.

Sorry, I'm not applying this.
