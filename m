From: David Miller <davem@davemloft.net>
Subject: Re: [Bug 7635] New: ioctl(fd,TCSBRK,1) on socket yields EFAULT,
 expected EINVAL/ENOTTY
Date: Fri, 08 Dec 2006 16:33:49 -0800 (PST)
Message-ID: <20061208.163349.74721527.davem@davemloft.net>
References: <20061208095055.38fef768@localhost>
	<20061208.133633.77400985.davem@davemloft.net>
	<20061208140021.27e9ab2d@freekitty>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38557
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1761296AbWLIAdj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Dec 2006 19:33:39 -0500
To: shemminger@osdl.org
In-Reply-To: <20061208140021.27e9ab2d@freekitty>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Hemminger <shemminger@osdl.org>
Date: Fri, 8 Dec 2006 14:00:21 -0800

> That is not true on BSD or other unix standardish ioctl's.
> There are no conflicts between the TIOC... values and the SIOC... values

There is absolutely nothing that we can do about this under
Linux without breaking every single application out there.

We allocated these values a long long time ago, before we
got the idea that we should perhaps use some kind of
macro system (as we mostly do now) to keep the values from
conflicting.

> Seems like one of those annoying standards compliance test
> return value bugs that shouldn't really hit an application.

Being non-compliant, and being unable to become compliant,
it actually a feature and a huge weight off of our shoulders,
don't you think?  :-)
