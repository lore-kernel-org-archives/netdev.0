From: David Miller <davem@davemloft.net>
Subject: Re: clarify code intent
Date: Thu, 18 Sep 2008 16:59:11 -0700 (PDT)
Message-ID: <20080918.165911.07741111.davem@davemloft.net>
References: <1221757668.23007.12.camel@ns-test>
	<20080918.163633.223533656.davem@davemloft.net>
	<1221782020.23007.37.camel@ns-test>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: mathieu.lacage@sophia.inria.fr
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40325
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1757364AbYIRX7X (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Sep 2008 19:59:23 -0400
In-Reply-To: <1221782020.23007.37.camel@ns-test>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mathieu Lacage <mathieu.lacage@sophia.inria.fr>
Date: Thu, 18 Sep 2008 16:53:40 -0700

> On Thu, 2008-09-18 at 16:36 -0700, David Miller wrote:
> 
> > This is just syntactic masterbation, sa_family_t is typedef'd
> > "unsigned short".
> 
> Would you take a patch to remove sa_family_t from the kernel code and
> headers ? Otherwise, I suspect that you can understand that it is a bit
> hard for others to figure out where it is appropriate to use it and
> where it is not.

No, that would break older userspace.
