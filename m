From: John Holland <jotihojr@gmail.com>
Subject: Re: [Intel-wired-lan] [next] igb: allow setting MAC address on i211 using a device tree blob V4
Date: Thu, 18 Feb 2016 08:53:07 +0100
Message-ID: <97579B9E-E7C6-4DBE-B1A2-027C2EA7F754@gmail.com>
References: <56C506FD.5040408@gmail.com> <20160217.212910.1758016077144502307.davem@davemloft.net>
Mime-Version: 1.0 (1.0)
Content-Type: text/plain;
	charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: intel-wired-lan@lists.osuosl.org, netdev@vger.kernel.org,
	jeffrey.t.kirsher@intel.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f48.google.com ([74.125.82.48]:37452 "EHLO
	mail-wm0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933542AbcBRHxK convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Feb 2016 02:53:10 -0500
Received: by mail-wm0-f48.google.com with SMTP id g62so12750052wme.0
        for <netdev@vger.kernel.org>; Wed, 17 Feb 2016 23:53:09 -0800 (PST)
In-Reply-To: <20160217.212910.1758016077144502307.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> On Feb 18, 2016, at 03:29, David Miller <davem@davemloft.net> wrote:
> 
> From: John Holland <jotihojr@gmail.com>
> Date: Thu, 18 Feb 2016 00:49:17 +0100
> 
>> The Intel i211 LOM pcie ethernet controllers' iNVM operates as an OTP
>> and has no externel EEPROM interface [1]. The following allows the
>> driver to pickup the MAC address from a device tree blob when
>> CONFIG_OF
>> has been enabled.
> 
> Please use the generic eth_platform_get_mac_address(), or
> alternatively structure your code like the ixgbe and other cases so
> that SPARC and other OF platforms get this support as well.

Don't know what you mean. The PCI path in eth_platform_get_mac_address() didn't return a devicetree node and I can find no instance of of_<function> use in ixgbe.

John
