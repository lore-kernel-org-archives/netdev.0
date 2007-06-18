From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] fix race in AF_UNIX
Date: Mon, 18 Jun 2007 02:18:13 -0700 (PDT)
Message-ID: <20070618.021813.105401188.davem@davemloft.net>
References: <E1I0BzQ-0006gZ-00@dorka.pomaz.szeredi.hu>
	<20070618.005711.21897961.davem@davemloft.net>
	<E1I0CTH-0006k3-00@dorka.pomaz.szeredi.hu>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: viro@ftp.linux.org.uk, alan@lxorguk.ukuu.org.uk,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: miklos@szeredi.hu
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54780
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755545AbXFRJRz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Jun 2007 05:17:55 -0400
In-Reply-To: <E1I0CTH-0006k3-00@dorka.pomaz.szeredi.hu>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Miklos Szeredi <miklos@szeredi.hu>
Date: Mon, 18 Jun 2007 10:20:23 +0200

> And is anyone working on a better patch?

I have no idea.

> Those patches aren't "bad" in the correctness sense.  So IMO any one
> of them is better, than having that bug in there.

You're adding a very serious performance regression, which is
about as bad as the bug itself.

It can wait for a more appropriate fix.
