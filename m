From: Francois Romieu <romieu@fr.zoreil.com>
Subject: 8139C+/8169 and suspend mode
Date: Sat, 25 Sep 2004 21:40:01 +0200
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <20040925194000.GA11363@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jgarzik@pobox.com, Jon Mason <jdmason@us.ibm.com>,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S269399AbUIYToQ@vger.kernel.org>
To: netdev@oss.sgi.com
Content-Disposition: inline
List-Id: netdev.vger.kernel.org

Does anyone have positive experience with suspend mode on the aforementionned
chipset ?

Rationale: Jon noticed that the r8169 driver did not correctly set the dirty
Rx ring index when the driver tries to reset the chipset (rtl8169_hw_start)
after a Tx timeout recovery. The chipset is told where the Tx/Rx rings start
but the software driver works with a badly inaccurate (rx_cur, rx_dirty) pair.

If I am not mistaken, the same pattern applies to the resume function in the
r8169 driver and in the 8139cp driver. 

So, despite me thinking that the poor thing is in a bad state, is there
anybody who actually succeeds using it ?

--
Ueimor
