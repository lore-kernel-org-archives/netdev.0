From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] [ETHTOOL]: EEPROM dump no longer works for tg3 and
 natsemi
Date: Thu, 24 Apr 2008 20:57:50 -0700 (PDT)
Message-ID: <20080424.205750.91351344.davem@davemloft.net>
References: <20080425022030.GA593@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, leitao@linux.vnet.ibm.com,
	thockin@google.com, jeff@garzik.org, joe@perches.com,
	nil@google.com, matthew@wil.cx
To: msb@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42823
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753996AbYDYD5u (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Apr 2008 23:57:50 -0400
In-Reply-To: <20080425022030.GA593@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mandeep Singh Baines <msb@google.com>
Date: Thu, 24 Apr 2008 19:20:30 -0700

> In the ethtool user-space application, tg3 and natsemi over-ride the default
> implementation of dump_eeprom(). In both tg3_dump_eeprom() and
> natsemi_dump_eeprom(), there is a magic number check which is not present in
> the default implementation.
> 
> Commit b131dd5d snipped the code which copied the ethtool_eeprom structure
> back to user-space. tg3 and natsemi are over-writing the magic number field
> and then checking it in user-space. With the ethtool_eeprom copy removed, the
> check is failing.
> 
> The fix is simple. Add the ethtool_eeprom copy back.
> 
> Signed-off-by: Mandeep Singh Baines <msb@google.com>

Patch applied, thank you for fixing this bug.

Could you make a minor modification to your changelog comments
in the future?  When referencing an SHA ID commit, please include
the header text line from the changelog.  In this way, if the
commit ID changes for whatever reason, people can still figure out
what commit you're referencing.

For example, I changed your second paragraph to read:

--------------------
    Commit b131dd5d ("[ETHTOOL]: Add support for large eeproms") snipped
    the code which copied the ethtool_eeprom structure back to
    user-space. tg3 and natsemi are over-writing the magic number field
    and then checking it in user-space. With the ethtool_eeprom copy
    removed, the check is failing.
--------------------

when I added your change.

Thanks!
