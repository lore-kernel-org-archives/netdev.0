From: John Holland <jotihojr@gmail.com>
Subject: Re: [Intel-wired-lan] [next] igb: allow setting MAC address on i211 using a device tree blob
Date: Wed, 10 Feb 2016 10:13:56 +0100
Message-ID: <0362A89D-78DF-4F09-A8B6-5A87FAA74AB9@gmail.com>
References: <56ABE3A8.4010602@gmail.com> <1455015744.3592.46.camel@intel.com> <20160209115430.GD18781@lunn.ch>
Mime-Version: 1.0 (1.0)
Content-Type: text/plain;
	charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	intel-wired-lan@lists.osuosl.org, netdev@vger.kernel.org
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f44.google.com ([74.125.82.44]:38496 "EHLO
	mail-wm0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751994AbcBJJOA convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Feb 2016 04:14:00 -0500
Received: by mail-wm0-f44.google.com with SMTP id p63so17322609wmp.1
        for <netdev@vger.kernel.org>; Wed, 10 Feb 2016 01:13:59 -0800 (PST)
In-Reply-To: <20160209115430.GD18781@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>




Sent from my iPad
On Feb 9, 2016, at 12:54, Andrew Lunn <andrew@lunn.ch> wrote:

>>> +static void igb_read_mac_addr_dts(struct e1000_hw *hw)
>>> +{
>>> +       const u8 *mac;
>>> +       struct device_node *dn;
>>> +
>>> +       dn = of_find_compatible_node(NULL, NULL, "intel,i211");
> 
> Hi John
> 
> Would this also work for the i210?

The usability scenario of i210 and i211 seem similar enough. Although, I will not be able to test the i210, I will use it as the compatible keyword.

> 
> If so, you normally use the compatible string for the first device
> this works with. So maybe this should be changed to intel,i210?
> 
> Thanks
>    Andrew
