From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [Intel-wired-lan] [next] igb: allow setting MAC address on i211
 using a device tree blob
Date: Tue, 9 Feb 2016 12:59:21 +0100
Message-ID: <20160209115921.GE18781@lunn.ch>
References: <56ABE3A8.4010602@gmail.com>
 <1455015744.3592.46.camel@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: John Holland <jotihojr@gmail.com>,
	intel-wired-lan@lists.osuosl.org, netdev@vger.kernel.org
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:52800 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752643AbcBIL7Y (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 Feb 2016 06:59:24 -0500
Content-Disposition: inline
In-Reply-To: <1455015744.3592.46.camel@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> > +=A0=A0=A0=A0=A0=A0=A0dn =3D of_find_compatible_node(NULL, NULL, "i=
ntel,i211");

Humm, NULL, NULL. That means find the first node anywhere in the
device tree which matches. This is not going to work too well when you
have multiple i211s.

There is a way so specify a DT node is attached to a specific PCIe
bus/slot. I think you should search only there, so solving the
multiple device issue.

	 Andrew
