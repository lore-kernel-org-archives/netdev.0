From: Amir Noam <amir.noam@intel.com>
Subject: [bonding] Add basic support for dynamic configuration of bond interfaces
Date: Thu, 8 Jan 2004 18:19:54 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200401081819.54484.amir.noam@intel.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: <bonding-devel@lists.sourceforge.net>, <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "Jeff Garzik" <jgarzik@pobox.com>, "Jay Vosburgh" <fubar@us.ibm.com>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

The following patch sets provide basic support for future bonding 
operations (specifically for dynamic configuration of bonding 
interfaces).

This is done by adding two new bonding ioctls: one for deviceless 
commands (an ioctl hook) and one for device oriented commands. Like 
ethtool, the first u32 value in the data structure will indicate the 
exact sub-command to be executed.

The sets are against the latest netdev-2.4 and net-drivers-2.5-exp 
trees.

-- 
Amir
