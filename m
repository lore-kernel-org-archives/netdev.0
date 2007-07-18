From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] net/, drivers/net/ , missing EXPERIMENTAL in menus
Date: Wed, 18 Jul 2007 16:45:21 -0400
Message-ID: <469E7BE1.6090401@garzik.org>
References: <469E75AA.7040109@pimpmylinux.org>	<Pine.LNX.4.64.0707181620460.13912@localhost.localdomain> <20070718134012.cde2f956.randy.dunlap@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Robert P. J. Day" <rpjday@mindspring.com>,
	Gabriel C <crazy@pimpmylinux.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org
To: Randy Dunlap <randy.dunlap@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:60488 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757654AbXGRUp1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 Jul 2007 16:45:27 -0400
In-Reply-To: <20070718134012.cde2f956.randy.dunlap@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Randy Dunlap wrote:
> On Wed, 18 Jul 2007 16:23:09 -0400 (EDT) Robert P. J. Day wrote:
>> there's no point adding all that redundant content when it can all be
>> done automatically.
> 
> I like it.  Are there any kconfig patches to support this plan?


Speaking specifically to adding 'EXPERIMENTAL', I distinctly remember at 
some point in the past the config system was smart enough to print " 
(EXPERIMENTAL)" if that entry depended on CONFIG_EXPERIMENTAL.

We should head in that direction.

I strongly NAK the original patch from Gabriel C in this thread -- it 
just adds too much redundant info.  Better to add it -once-, somewhere 
inside Kconfig system.

	Jeff


