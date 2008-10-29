From: David Miller <davem@davemloft.net>
Subject: oh crap... (re: %p6)
Date: Wed, 29 Oct 2008 01:54:02 -0700 (PDT)
Message-ID: <20081029.015402.234525839.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: harvey.harrison@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37203
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751350AbYJ2Iy1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Oct 2008 04:54:27 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


I think we'll need to revert all of this or find some fix soon.  GCC
warns about %p with a '#' flag modifier it seems :-(

net/ipv6/ip6_flowlabel.c: In function 'ip6fl_seq_show':
net/ipv6/ip6_flowlabel.c:707: warning: '#' flag used with '%p' printf format

this is with:

davem@sunset:~/src/GIT/net-next-2.6$ gcc --version
gcc (GCC) 4.1.3 20070929 (prerelease) (Ubuntu 4.1.2-16ubuntu2)
Copyright (C) 2006 Free Software Foundation, Inc.
This is free software; see the source for copying conditions.  There is NO
warranty; not even for MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

davem@sunset:~/src/GIT/net-next-2.6$ 
