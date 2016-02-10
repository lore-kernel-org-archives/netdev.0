From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [Intel-wired-lan] [next] igb: allow setting MAC address on i211
 using a device tree blob
Date: Wed, 10 Feb 2016 17:59:25 +0100
Message-ID: <20160210165925.GA9492@lunn.ch>
References: <56ABE3A8.4010602@gmail.com>
 <1455015744.3592.46.camel@intel.com>
 <20160209115430.GD18781@lunn.ch>
 <0362A89D-78DF-4F09-A8B6-5A87FAA74AB9@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	intel-wired-lan@lists.osuosl.org, netdev@vger.kernel.org
To: John Holland <jotihojr@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:53818 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752240AbcBJQ7c (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 10 Feb 2016 11:59:32 -0500
Content-Disposition: inline
In-Reply-To: <0362A89D-78DF-4F09-A8B6-5A87FAA74AB9@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Feb 10, 2016 at 10:13:56AM +0100, John Holland wrote:
> 
> 
> 
> Sent from my iPad
> On Feb 9, 2016, at 12:54, Andrew Lunn <andrew@lunn.ch> wrote:
> 
> >>> +static void igb_read_mac_addr_dts(struct e1000_hw *hw)
> >>> +{
> >>> +       const u8 *mac;
> >>> +       struct device_node *dn;
> >>> +
> >>> +       dn = of_find_compatible_node(NULL, NULL, "intel,i211");
> > 
> > Hi John
> > 
> > Would this also work for the i210?
> 

> The usability scenario of i210 and i211 seem similar
> enough. Although, I will not be able to test the i210, I will use it
> as the compatible keyword.

I can test on i210.

  Andrew
