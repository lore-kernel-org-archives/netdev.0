From: Ganesh Venkatesan <ganesh.venkatesan@intel.com>
Subject: [PATCH 2.6 0/9] ixgb: driver update
Date: Thu, 6 Jan 2005 17:22:38 -0800 (PST)
Message-ID: <Pine.LNX.4.44.0501061545000.7330-100000@isotope.jf.intel.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "jgarzik@pobox.com" <jgarzik@pobox.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

1 Enabling MSI on a PCI slot (not PCI-X) may not work, so always disable MSI for PCI slots, enable message signalled interrupts on 82597EX based adapters
2 Limit number of Rx descriptors to 512.
3 Add support for LR device ID
4 Include Tx workdone in deciding when to quit polling, Robert Olsson's fix for NAPI quit condition, avoid polling routine racing with the interface down routine
5 Fix ordering of elements in ixgb_buffer to avoid padding by the 
compiler.
6 Fix tx cleanup logic error.
7 Remove support for RAIDC interrupt moderation.
8 Support for 2.6.x style module parameters
9 White space/driver version number update.
