From: "Kweh, Hock Leong" <hock.leong.kweh@intel.com>
Subject: RE: [PATCH v2 3/4] net: stmmac: add support for Intel Quark X1000
Date: Mon, 15 Sep 2014 12:42:03 +0000
Message-ID: <F54AEECA5E2B9541821D670476DAE19C2B7E99A7@PGSMSX102.gar.corp.intel.com>
References: <cover.1410416223.git.hock.leong.kweh@intel.com>
	<cover.1410416223.git.hock.leong.kweh@intel.com>
	<07ca9d2c89cf4f01037c98e3314dd035e4d2ee34.1410416224.git.hock.leong.kweh@intel.com>
 <20140912.181423.1831537443587796533.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "peppe.cavallaro@st.com" <peppe.cavallaro@st.com>,
	"rayagond@vayavyalabs.com" <rayagond@vayavyalabs.com>,
	"vbridgers2013@gmail.com" <vbridgers2013@gmail.com>,
	"srinivas.kandagatla@st.com" <srinivas.kandagatla@st.com>,
	"wens@csie.org" <wens@csie.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"Ong, Boon Leong" <boon.leong.ong@intel.com>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140912.181423.1831537443587796533.davem@davemloft.net>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> -----Original Message-----
> From: David Miller [mailto:davem@davemloft.net]
> Sent: Saturday, September 13, 2014 6:14 AM
> From: Kweh Hock Leong <hock.leong.kweh@intel.com>
> Date: Thu, 11 Sep 2014 16:38:39 +0800
> 
> > +		if ((!strcmp(quark_x1000_phy_info[i].board_name,
> board_name)) &&
> > +		    quark_x1000_phy_info[i].pci_func_num == func_num)
> 
> It is entirely erroneous to identify a device by it's _PHYSICAL_ geographic
> location on the PCI bus.
> 
> Please get rid of this PCI function number comparison and if necessary find
> another means of identification.

Hi David,

Here is some background of this work. Intel Quark X1000 has 2 stmmac Ethernet IP
built in the SoC. They both are using the same PCI DEVICE ID number. The only things 
to differentiate them is PCI BUS DEVICE FUNCTION (Bus:Dev:Func) number which are
fix numbers 00:20:6 for port 1 and 00:20:7 for port 2 stated in Quark X1000 datasheet.
(https://communities.intel.com/docs/DOC-23092 page 44 & 97)

When I was looking into making the code to upstream, I do think about is there a better
identification way to do it? But, my mind still brought me back to this PCI FUNC number.

So, i would like to understand the concern of using PCI FUNC number and also would like
to see is there any advices, suggestion or pointer to deal with the scenario here.

Appreciate to the comments sharing. Thanks.


Regards,
Wilson
