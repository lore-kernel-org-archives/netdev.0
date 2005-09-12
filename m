From: "John W. Linville" <linville@tuxdriver.com>
Subject: [patch 2.6.13 0/5] normalize calculations of rx_dropped
Date: Mon, 12 Sep 2005 10:48:58 -0400
Message-ID: <09122005104858.332@bilbo.tuxdriver.com>
References: <20050822181726.GJ2736@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, akpm@osdl.org, john.ronciak@intel.com,
	ganesh.venkatesan@intel.com, cramerj@intel.com,
	jesse.brandeburg@intel.com, ayyappan.veeraiyan@intel.com,
	mchan@broadcom.com, davem@davemloft.net
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751356AbVILO7M@vger.kernel.org>
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
In-Reply-To: <20050822181726.GJ2736@tuxdriver.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Some fixes to normalize how rx_dropped is calculated.  This is the
product of a discussion on netdev on or about 18 August 2005 w/
the subject '[RFC] stats: how to count "good" packets dropped by
hardware?'

Patches for 3c59x, e1000, e100, ixgb, and tg3 to follow.
