From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 3/4] net: stmmac: add support for Intel Quark X1000
Date: Tue, 16 Sep 2014 15:00:37 -0400 (EDT)
Message-ID: <20140916.150037.1715537913178712290.davem@davemloft.net>
References: <07ca9d2c89cf4f01037c98e3314dd035e4d2ee34.1410416224.git.hock.leong.kweh@intel.com>
	<20140912.181423.1831537443587796533.davem@davemloft.net>
	<F54AEECA5E2B9541821D670476DAE19C2B7E99A7@PGSMSX102.gar.corp.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: peppe.cavallaro@st.com, rayagond@vayavyalabs.com,
	vbridgers2013@gmail.com, srinivas.kandagatla@st.com, wens@csie.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	boon.leong.ong@intel.com
To: hock.leong.kweh@intel.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <F54AEECA5E2B9541821D670476DAE19C2B7E99A7@PGSMSX102.gar.corp.intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Kweh, Hock Leong" <hock.leong.kweh@intel.com>
Date: Mon, 15 Sep 2014 12:42:03 +0000

> The only things to differentiate them is PCI BUS DEVICE FUNCTION
> (Bus:Dev:Func) number which are fix numbers 00:20:6 for port 1 and
> 00:20:7 for port 2 stated in Quark X1000 datasheet.

Match on the PCI device class, which must be PCI_CLASS_NETWORK_ETHERNET
or similar.

The pci_device_id used for probing supports matching on this directly.
.
