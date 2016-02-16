From: John Holland <jotihojr@gmail.com>
Subject: Re: [Intel-wired-lan] [next] igb: allow setting MAC address on i211 using a device tree blob V2
Date: Tue, 16 Feb 2016 23:34:07 +0100
Message-ID: <255BB17A-515B-467A-8ED6-96F1173D233E@gmail.com>
References: <56BFA87D.1010609@gmail.com> <20160216165850.GF29482@lunn.ch>
Mime-Version: 1.0 (1.0)
Content-Type: text/plain;
	charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: intel-wired-lan@lists.osuosl.org, netdev@vger.kernel.org
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f51.google.com ([74.125.82.51]:34629 "EHLO
	mail-wm0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756115AbcBPWeK convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Feb 2016 17:34:10 -0500
Received: by mail-wm0-f51.google.com with SMTP id b205so130819234wmb.1
        for <netdev@vger.kernel.org>; Tue, 16 Feb 2016 14:34:09 -0800 (PST)
In-Reply-To: <20160216165850.GF29482@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> On Feb 16, 2016, at 17:58, Andrew Lunn <andrew@lunn.ch> wrote:
> 
>> On Sat, Feb 13, 2016 at 11:04:45PM +0100, John Holland wrote:
>> Hello,
>> 
>> The Intel i211 LOM pcie ethernet controllers' iNVM operates as an
>> OTP and has no externel EEPROM interface [1]. The following allows
>> the driver to pickup the MAC address from a device tree blob when
>> CONFIG_OF has been enabled.
>> 
>> [1] http://www.intel.com/content/www/us/en/embedded/products/networking/i211-ethernet-controller-datasheet.html
>> 
>> Changes V2
>> - Restrict searching for compatible devices to current pci device.
>> 
>> Signed-off-by: John Holland <jotihojr@gmail.com>
> 
> Hi John
> 
> Thanks for fixing multiple device support.
> 
> Please could you add documentation in
> Documentation/devicetree/bindings/net. I know these are standard
> properties, but it is somewhat unusual to attach them to a PCI node,
> so having an example would be good.
> 
>   Thanks
>    Andrew

Odd that the marvel sky2 allows just that, but supplies no documentation.

I can supply some kind of usage description/example, showing how to use this feature to pull in the MAC address from u-boot and route it to the i210. Just uncertain as how to name the respective file. igb.txt or i210.txt come to mind. Do you prefer one over the other?

John
