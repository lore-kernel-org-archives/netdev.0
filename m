From: Jarek Poplawski <jarkao2@o2.pl>
Subject: Re: NETPOLL=y , NETDEVICES=n compile error ( Re: 2.6.23-rc1-mm1 )
Date: Tue, 31 Jul 2007 14:47:25 +0200
Message-ID: <20070731124725.GB1046@ff.dom.local>
References: <20070731083210.GA1797@ff.dom.local> <46AF0B8C.7070006@googlemail.com> <46AF20B4.4050203@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Gabriel C <nix.or.die@googlemail.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	amitkale@linsyssoft.com
To: Jason Wessel <jason.wessel@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx12.go2.pl ([193.17.41.142]:44497 "EHLO poczta.o2.pl"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750847AbXGaMh6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 31 Jul 2007 08:37:58 -0400
Content-Disposition: inline
In-Reply-To: <46AF20B4.4050203@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jul 31, 2007 at 06:44:52AM -0500, Jason Wessel wrote:
...
> kgdboe is completely useless without a network card that has a polling 
> driver.  It seems to me that the simple and easy fix is to set it to 
> depend on NETDEVICES but allow it to use select on NETPOLL.

Maybe I miss your point but polling drivers don't need NETPOLL
to work (unless you need netconsole). But I don't know if there
is any easy method to check such driver's dependency with select.

Jarek P.
