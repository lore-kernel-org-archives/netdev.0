From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: circular locking, mirred, 2.6.24.2
Date: Mon, 25 Feb 2008 11:39:30 +0000
Message-ID: <20080225113930.GA4733@ff.dom.local>
References: <20080224222035.M62480@visp.net.lb> <20080225095646.GA4321@ff.dom.local> <20080225104652.M2446@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Denys Fedoryshchenko <denys@visp.net.lb>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.169]:26405 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753243AbYBYLi3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Feb 2008 06:38:29 -0500
Received: by ug-out-1314.google.com with SMTP id z38so749373ugc.16
        for <netdev@vger.kernel.org>; Mon, 25 Feb 2008 03:38:27 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20080225104652.M2446@visp.net.lb>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Feb 25, 2008 at 12:48:38PM +0200, Denys Fedoryshchenko wrote:
> What does it mean early?
> I have custom boot scripts, it is also custom system based on busybox. There 
> is a chance that i forgot to bring ifb0 up, but thats it.
> I think such warning must not appear on any actions in userspace.

It's not about ifb0: this report shows loopback_init after some action
on eth, so eth was probably up before lo. And of course you are right:
this warning shouldn't be there. But, since this report looks very
strange, I wonder if there could be something else that mislead
lockdep. Could you try to reproduce this with 2.6.24.2 without these
additional patches?

Jarek P.
