From: Matthew Wilcox <willy@debian.org>
Subject: Bonding driver makes bad use of ethtool
Date: Fri, 12 Sep 2003 15:27:30 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030912142730.GA21596@parcelfarce.linux.theplanet.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: bonding-devel@lists.sourceforge.net, Amir Noam <amir.noam@intel.com>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


ethtool is being abused by the bonding driver.  ifenslave is passing
in which ABI version it wants to use via the ETHTOOL_GDRVINFO call.
This cannot continue in the ethtool_ops scheme, and it's my opinion this
shouldn't've been done in the first place.

I suggest a new ioctl to set your ABI version and delete this bad use
of ETHTOOL_GDRVINFO.

-- 
"It's not Hollywood.  War is real, war is primarily not about defeat or
victory, it is about death.  I've seen thousands and thousands of dead bodies.
Do you think I want to have an academic debate on this subject?" -- Robert Fisk
