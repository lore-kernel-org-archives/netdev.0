From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] (0/16) intro to IRDA patches for 2.6.0-test6
Date: Tue, 30 Sep 2003 15:25:30 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030930152530.1e279c29.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, irda-users@lists.sourceforge.net
Return-path: <netdev-bounce@oss.sgi.com>
To: Jean Tourrilhes <jt@bougret.hpl.hp.com>,
        "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

These patches are a replacement for the moderate one chunk I sent out yesterday.
They continue in the same vein of revising how IRDA devices are allocated.
The new thing is the introduction of alloc_irdadev and changing over the places
I used alloc_netdev to that.

Mostly they are trivial, but smsc-ircc2 got changed to get rid of check_region
usage as well.

David, please apply after Jean gives his approval.
