From: David Miller <davem@davemloft.net>
Subject: Re: net/ipv4/inetpeer.c stack warnings
Date: Fri, 20 Jul 2007 19:39:26 -0700 (PDT)
Message-ID: <20070720.193926.92584343.davem@davemloft.net>
References: <469F5941.7090900@googlemail.com>
	<469F5DBB.3080106@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nix.or.die@googlemail.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:32934
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1759062AbXGUCj1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Jul 2007 22:39:27 -0400
In-Reply-To: <469F5DBB.3080106@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Patrick McHardy <kaber@trash.net>
Date: Thu, 19 Jul 2007 14:48:59 +0200

> Gabriel C wrote:
> > Hello ,
> >
> > I noticed on current git this warning in net/ipv4/inetpeer.c
> 
> Yeah, I have no idea why the gcc people thought that this was
> something worth warning about. Especially since explicitly
> checking for != NULL silences the warning again.

Sigh, applied :-)
