From: David Miller <davem@davemloft.net>
Subject: fib_hash removal
Date: Wed, 14 Mar 2007 15:44:14 -0700 (PDT)
Message-ID: <20070314.154414.97293857.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Robert.Olsson@data.slu.se, tgr@suug.ch
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38695
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753316AbXCNWoQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Mar 2007 18:44:16 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Another thing I'd like to accomplish is to kill off
fib_hash leaving just fib_trie.

I can't do that until any and all functionality regressions
which may or may not exist in fib_trie vs. fib_hash are
discussed and resolved.

So can we start composing a list of stuff to look into in this
thread so work can begin in that area?  My goal would be to
target 2.6.23 for the removal, and getting this plus the
multipath cached stuff killed would be something truly worth
celebrating :-)
