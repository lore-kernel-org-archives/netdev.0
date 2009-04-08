From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: Re: Creating an Ethernet subtype setting
Date: Wed, 8 Apr 2009 23:00:33 +0200
Message-ID: <20090408210033.GB13160@xi.wantstofly.org>
References: <1238071318.8206.18.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Marcel Holtmann <marcel@holtmann.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xi.wantstofly.org ([80.101.37.227]:46950 "EHLO
	xi.wantstofly.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753682AbZDHVAe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Apr 2009 17:00:34 -0400
Content-Disposition: inline
In-Reply-To: <1238071318.8206.18.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 26, 2009 at 01:41:58PM +0100, Marcel Holtmann wrote:

> so we have more and more subsystem that expose themselves as Ethernet
> networking devices and it really becomes hard to identify them in an
> easy way. For example WiFi has been an Ethernet device since a long time
> now and distinguishing between Ethernet and WiFi is not that hard since
> we have the good old WEXT ioctls to identify WiFi devices. However with
> WiMAX, Bluetooth, GSM/CDMA modems and even Ethernet bridge devices,

Also:
- VLAN interfaces
- TAP interfaces
- ETH_P_TEB
- (DSA interfaces)
