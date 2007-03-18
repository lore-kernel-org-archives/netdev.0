From: Divy Le Ray <divy@chelsio.com>
Subject: [PATCH 2.6.21 0/4] cxgb3 - bug fixes
Date: Sun, 18 Mar 2007 12:09:26 -0800
Message-ID: <45FD9C76.3040503@chelsio.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org,
	Steve Wise <swise@opengridcomputing.com>
To: Jeff Garzik <jeff@garzik.org>, netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S933115AbXCRUJg@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Jeff,

I'm submitting a set of bug fixes for inclusion in 2.6.21.
The patches are built against Linus'git tree.

Here is a brief description:
- ethtool -g/G should only apply to queue sets bound to the given port,
- the driver will attempt to load the FW if it hits a version mismatch,
- monitor the MAC for a potential hang, and triggers a recovery mechanism
  for the T3B2 asic ,
- T3B2 does not lose its pcie config space on reset.

Cheers,
Divy
