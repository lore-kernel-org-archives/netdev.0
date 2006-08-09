From: Dave Jones <davej@redhat.com>
Subject: IPX changes introduce warning.
Date: Wed, 9 Aug 2006 19:44:17 -0400
Message-ID: <20060809234417.GA23634@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, acme@ghostprotocols.net,
	netdev@vger.kernel.org, greg@kroah.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:63902 "EHLO mx1.redhat.com")
	by vger.kernel.org with ESMTP id S1751174AbWHIXpQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Aug 2006 19:45:16 -0400
To: Stephen Hemminger <shemminger@osdl.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

We've just added an implicit declaration in the latest tree..

net/ipx/af_ipx.c: In function 'ipx_rcv':
net/ipx/af_ipx.c:1648: error: implicit declaration of function 'ipxhdr'

(Yes, my builds fail on -Werror-implicit, so that things like this get caught early)

Probably something simple like a missing #include, but I'm heading out
the door right now :)  I'll poke at it later if no-one has beaten me to it.

		Dave

-- 
http://www.codemonkey.org.uk
