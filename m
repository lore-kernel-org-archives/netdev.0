From: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Subject: [PATCH 0/2] REPOST: Multiqueue network device support
Date: Mon, 09 Apr 2007 14:27:23 -0700
Message-ID: <20070409212723.31670.27976.stgit@gitlost.site>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	jgarzik@pobox.com, cramerj@intel.com, auke-jan.h.kok@intel.com,
	christopher.leech@intel.com
To: davem@davemloft.net
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S965847AbXDIVMi@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Reposting due to the patches getting bounced by majordomo:

This is a redesign and repost of the multiqueue network device support
patches.  The new API for base drivers allows multiqueue-capable devices to
manage their individual queues in the network stack.  The stack now handles
both non-multiqueue and multiqueue devices on the same codepath.  Also,
allocation and deallocation of the queues is handled by the kernel instead
of the driver.

Documentation is also included describing in more detail how this works, as
well as how a base driver can use the API to implement multiple queues.

These patches can also be pulled from my git repository at:

        git-pull git://lost.foo-projects.org/~ppwaskie/git/net-2.6.22 mq

--
Peter P. Waskiewicz Jr.
peter.p.waskiewicz.jr@intel.com
