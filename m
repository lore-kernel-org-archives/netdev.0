From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v4] cdc_ether: Improve ZTE MF823/831/910
 handling
Date: Sun, 24 Jul 2016 22:16:32 -0700 (PDT)
Message-ID: <20160724.221632.1884613172751944584.davem@davemloft.net>
References: <1469092206-5749-1-git-send-email-kristian.evensen@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: oliver@neukum.org, linux-usb@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: kristian.evensen@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:58506 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750844AbcGYFQd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Jul 2016 01:16:33 -0400
In-Reply-To: <1469092206-5749-1-git-send-email-kristian.evensen@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kristian Evensen <kristian.evensen@gmail.com>
Date: Thu, 21 Jul 2016 11:10:06 +0200

> The firmware in several ZTE devices (at least the MF823/831/910
> modems/mifis) use OS fingerprinting to determine which type of device to
> export. In addition, these devices export a REST API which can be used to
> control the type of device. So far, on Linux, the devices have been seen as
> RNDIS or CDC Ether.
> 
> When CDC Ether is used, devices of the same type are, as with RNDIS,
> exported with the same, bogus random MAC address. In addition, the devices
> (at least on all firmware revisions I have found) use the bogus MAC when
> sending traffic routed from external networks. And as a final feature, the
> devices sometimes export the link state incorrectly. There are also
> references online to several other ZTE devices displaying this behavior,
> with several different PIDs and MAC addresses.
> 
> This patch tries to improve the handling of ZTE devices by doing the
> following:
 ...
> v3->v4:
> * Forgot to remove unused variables, sorry about that (thanks David
> Miller).

Applied, thanks.
