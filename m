From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [v3,net-next] net: phy: Add Edge-rate driver for Microsemi PHYs.
Date: Tue, 27 Sep 2016 23:14:36 +0200
Message-ID: <20160927211436.GA11602@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>
To: Raju.Lakkaraju@microsemi.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:34719 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751382AbcI0VOi (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 27 Sep 2016 17:14:38 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I just realised the possibly correct binding was starring me in the
face.

--------------------------------------------------------------|
|  3.3V	 	2.5V  		1.8V  		1.5V          |
|-------------------------------------------------------------|
|-2%		-3%		-5%		-6%           |
|-------------------------------------------------------------|
|-4%		-6%		-9%		-14%          |
|-------------------------------------------------------------|
|-7%		-10%		-16%		-21%          |
|-------------------------------------------------------------|
|-10%		-14%		-23%		-29%          |
|-------------------------------------------------------------|
|-17%		-23%		-35%		-42%          |
|-------------------------------------------------------------|
|-29%		-37%		-52%		-58%          |
|-------------------------------------------------------------|
|-53%		-63%		-76%		-77%          |
|-------------------------------------------------------------|

So the binding is:

vsc8531,vddmac		: The vddmac in mV.
vsc8531,edge-slowdown	: % the edge should be slowed down relative to
                          the fastest possible edge time.

Given those two values, the driver can work out the magic value to put
into the register that nobody knows the true meaning of.

     Andrew
