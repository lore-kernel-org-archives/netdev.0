From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 3/4] net: stmmac: add support for Intel Quark X1000
Date: Fri, 12 Sep 2014 18:14:23 -0400 (EDT)
Message-ID: <20140912.181423.1831537443587796533.davem@davemloft.net>
References: <cover.1410416223.git.hock.leong.kweh@intel.com>
	<cover.1410416223.git.hock.leong.kweh@intel.com>
	<07ca9d2c89cf4f01037c98e3314dd035e4d2ee34.1410416224.git.hock.leong.kweh@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: peppe.cavallaro@st.com, rayagond@vayavyalabs.com,
	vbridgers2013@gmail.com, srinivas.kandagatla@st.com, wens@csie.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	boon.leong.ong@intel.com
To: hock.leong.kweh@intel.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <07ca9d2c89cf4f01037c98e3314dd035e4d2ee34.1410416224.git.hock.leong.kweh@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Kweh Hock Leong <hock.leong.kweh@intel.com>
Date: Thu, 11 Sep 2014 16:38:39 +0800

> +		if ((!strcmp(quark_x1000_phy_info[i].board_name, board_name)) &&
> +		    quark_x1000_phy_info[i].pci_func_num == func_num)

It is entirely erroneous to identify a device by it's _PHYSICAL_ geographic
location on the PCI bus.

Please get rid of this PCI function number comparison and if necessary
find another means of identification.
