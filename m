From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: Micrel Phy - Is there a way to configure the Phy not to do 802.3x
 flow control?
Date: Thu, 3 Mar 2016 16:16:23 -0800
Message-ID: <56D8D3D7.6070900@gmail.com>
References: <56D8B83E.7000303@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
To: Murali Karicheri <m-karicheri2@ti.com>, johan@kernel.org,
	"open list:TI NETCP ETHERNET DRIVER" <netdev@vger.kernel.org>,
	"Kwok, WingMan" <w-kwok2@ti.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f173.google.com ([209.85.192.173]:32949 "EHLO
	mail-pf0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932456AbcCDARt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Mar 2016 19:17:49 -0500
Received: by mail-pf0-f173.google.com with SMTP id 124so24193434pfg.0
        for <netdev@vger.kernel.org>; Thu, 03 Mar 2016 16:17:49 -0800 (PST)
In-Reply-To: <56D8B83E.7000303@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/03/16 14:18, Murali Karicheri wrote:
> Hi,
> 
> We are using Micrel Phy in one of our board and wondering if we can force the
> Phy to disable flow control at start. I have a 1G ethernet switch connected
> to Phy and the phy always enable flow control. I would like to configure the
> phy not to flow control. Is that possible and if yes, what should I do in the
> my Ethernet driver to tell the Phy not to enable flow control?

The PHY is not doing flow control per-se, your pseudo Ethernet MAC in
the switch is doing, along with the link partner advertising support for
it. You would want to make sure that your PHY device interface (provided
that you are using the PHY library) is not starting with Pause
advertised, but it could be supported.

As Andrew indicated the proper way to do this is do to use ethtool if
you need to this dynamically.
-- 
Florian
