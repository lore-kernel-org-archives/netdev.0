From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [Intel-wired-lan] [next] igb: allow setting MAC address on i211
 using a device tree blob
Date: Tue, 9 Feb 2016 12:54:30 +0100
Message-ID: <20160209115430.GD18781@lunn.ch>
References: <56ABE3A8.4010602@gmail.com>
 <1455015744.3592.46.camel@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: John Holland <jotihojr@gmail.com>,
	intel-wired-lan@lists.osuosl.org, netdev@vger.kernel.org
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:52790 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754761AbcBILyh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 Feb 2016 06:54:37 -0500
Content-Disposition: inline
In-Reply-To: <1455015744.3592.46.camel@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> > +static void igb_read_mac_addr_dts(struct e1000_hw *hw)
> > +{
> > +=A0=A0=A0=A0=A0=A0=A0const u8 *mac;
> > +=A0=A0=A0=A0=A0=A0=A0struct device_node *dn;
> > +
> > +=A0=A0=A0=A0=A0=A0=A0dn =3D of_find_compatible_node(NULL, NULL, "i=
ntel,i211");

Hi John

Would this also work for the i210?

If so, you normally use the compatible string for the first device
this works with. So maybe this should be changed to intel,i210?

Thanks
	Andrew
