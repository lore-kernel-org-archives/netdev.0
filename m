From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [Bonding-devel] [BUG] kernel panic on ifconfig bond0 down
Date: Thu, 18 Sep 2003 09:40:43 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200309181640.h8IGehSx015526@death.ibm.com>
References: <shmulik.hen@intel.com>
Cc: "Ned Bass" <bass6@llnl.gov>, bonding-devel@lists.sourceforge.net,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: shmulik.hen@intel.com
In-Reply-To: Message from Shmulik Hen <shmulik.hen@intel.com>
   of "Thu, 18 Sep 2003 12:42:58 +0300." <200309181242.58258.shmulik.hen@intel.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


>There was a bug in patch 8 of the cleanup set that left a dangling 
>pointer in bond_release_all(). Definitely may bad for not announcing 
>that (and removing the patch set from SFG ?). I was relying on the 
>fact that people won't test it after I announced the set needs to be 
>re-done after finding a potential bug in patch 5.
>
>I'm currently in the final stages of re-creating the set after 
>implementing the bug fixes and doing some improvements resulting from 
>internal code reviews. Perhaps this time I should publish it as an 
>"experimental" patch set and give everyone a chance to try it out 
>while our QA group grinds it to dust.

	I think there's still problems in the checked in code.  I did
my tests on 2.6.0-test5 plus 2.6.0-test5-bk2-netdrvr1, which doesn't
include the cleanup set, so there's at least one (potential sleep with
lock held in bond_mii_monitor()), possibly two, other bugs.  I'm
getting ready to do some tests with 2.4.23-pre4 to see what I find.

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
