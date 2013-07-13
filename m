From: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Subject: Re: Fixed PHY Device Tree usage?
Date: Sat, 13 Jul 2013 19:02:06 +0200
Message-ID: <20130713190206.2a617983@skate>
References: <20130709183312.6c4d052d@skate>
	<CAGVrzcZ7ZLSDy5sTUR_XuSAUH=5q8ddiXx5n1y680WwGrdFfTw@mail.gmail.com>
	<1733937.SiPWt3mDlH@lenovo>
	<20130710182216.0dcfaaaf@skate>
	<CAGVrzcbt302tTM3pprnhJz7YykUzcW=XSMCr_W=m1zWiVBX8kw@mail.gmail.com>
	<20130710183951.09a0bcea@skate>
	<CAGVrzcasmv6KvEN+okkcQA9CHjCtuRqcd=AvKLiFbPXiyS-P=w@mail.gmail.com>
	<CACxGe6tzMhjH8nxJ1Ezrc43DqCmv-pWRW2NsXa=fP-6Fh_t5PA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Florian Fainelli <florian@openwrt.org>,
	netdev <netdev@vger.kernel.org>,
	Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>,
	Gregory =?UTF-8?B?Q2zDqW1lbnQ=?=
	<gregory.clement@free-electrons.com>,
	Ezequiel Garcia <ezequiel.garcia@free-electrons.com>,
	Lior Amsalem <alior@marvell.com>,
	"devicetree-discuss@lists.ozlabs.org"
	<devicetree-discuss@lists.ozlabs.org>,
	Andy Fleming <afleming@freescale.com>
To: Grant Likely <grant.likely@secretlab.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.free-electrons.com ([94.23.35.102]:52751 "EHLO
	mail.free-electrons.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751071Ab3GMRCP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 13 Jul 2013 13:02:15 -0400
In-Reply-To: <CACxGe6tzMhjH8nxJ1Ezrc43DqCmv-pWRW2NsXa=fP-6Fh_t5PA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dear Grant Likely,

On Fri, 12 Jul 2013 23:44:21 +0100, Grant Likely wrote:

> I think this discussion is going in the wrong direction. The concept
> of a dummy phy is really a Linux kernel internal detail. Creating some
> kind of dummy MDIO bus node does not describe the hardware.

This is exactly what I was suggesting in my original e-mail of this
thread, see http://marc.info/?l=linux-netdev&m=137338762627063&w=2 :

"""
One option is to implement a Device Tree binding for the fixed PHY
driver (the exact DT binding would have to be discussed), but I'm
wondering whether describing a fixed PHY in the DT is actually correct,
because describing a fixed PHy is not really describing the hardware,
the hardware is actually a switch.
"""

> There is
> already support in the kernel for Ethernet MACs connected directly to
> a switch or other device. It is far better to describe how the MAC
> needs to be configured than to invent a non-existent phy. Search for
> "fixed-link" in the kernel tree to see how it is used.

As Florian pointed out, the of_phy_connect_fixed_link() comment
indicates:

 * This function is a temporary stop-gap and will be removed soon.  It is
 * only to support the fs_enet, ucc_geth and gianfar Ethernet drivers. Do
 * not call this function from new drivers.

Also, it would probably be good to have a few more helpers to make
parsing the "phy" and "fixed-link" property easier for network drivers.

Thanks for your feedback,

Thomas
-- 
Thomas Petazzoni, Free Electrons
Kernel, drivers, real-time and embedded Linux
development, consulting, training and support.
http://free-electrons.com
