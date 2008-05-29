From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: add ability to clear stats via ethtool -
 e1000/pcnet32
Date: Thu, 29 May 2008 13:50:55 -0700 (PDT)
Message-ID: <20080529.135055.193706538.davem@davemloft.net>
References: <483EA2D1.8050603@sngx.net>
	<20080529154525.3916c7b5@core>
	<483EE4A4.20508@sngx.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: alan@lxorguk.ukuu.org.uk, akpm@linux-foundation.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: jimi@sngx.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38429
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751065AbYE2Uu7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 May 2008 16:50:59 -0400
In-Reply-To: <483EE4A4.20508@sngx.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: James Cammarata <jimi@sngx.net>
Date: Thu, 29 May 2008 12:15:16 -0500

>  I'd be more than happy to change this to a kernel config
> option, experimental and default off for those who would not want it.

We never add pieces of code which are marked experimental and
intended to be marked that way forever, that's nonsense.

What you want is your little special kernel hack in the upstream
tree, and that's now how we handle such things, sorry.

I also agree with Alan that the kernel is the wrong place to
handle this problem.  Do it in userspace.

We have consistent precedence for this elsewhere in the kernel tree,
and there is good reason for that.
