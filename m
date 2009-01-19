From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: Re: 802.1Q support?
Date: Mon, 19 Jan 2009 10:17:30 +0100
Message-ID: <20090119091730.GD17124@xi.wantstofly.org>
References: <200901121148.26905.rgetz@blackfin.uclinux.org> <200901122143.51004.florian@openwrt.org> <200901130731.20538.rgetz@blackfin.uclinux.org> <200901131429.41178.florian@openwrt.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Robin Getz <rgetz@blackfin.uclinux.org>,
	Felix Fietkau <nbd@openwrt.org>, netdev@vger.kernel.org
To: Florian Fainelli <florian@openwrt.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xi.wantstofly.org ([80.101.37.227]:54671 "EHLO
	xi.wantstofly.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755117AbZASJRb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Jan 2009 04:17:31 -0500
Content-Disposition: inline
In-Reply-To: <200901131429.41178.florian@openwrt.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 13, 2009 at 02:29:39PM +0100, Florian Fainelli wrote:

> Lennert Buytenhek also proposed a Distributed Switch Architecture which is 
> worth looking at, though it does not cover more "classical" switches 
> connection over GPIO, SPI or special PHY address.

That's just because there are no drivers for switches that connect over
GPIO or SPI yet.  The only thing needed would be an extra field in the
platform data saying which connection method to use, which would be maybe
100 lines of patch at most.

(FWIW, when you use 88e6xxx switches in multi-chip addressing mode, they
do listen to one special PHY address only.)
