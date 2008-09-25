From: Tino Keitel <tino.keitel@gmx.de>
Subject: Re: Regression in 2.6.27-rc7: Wake On LAN with sky2 broken
Date: Thu, 25 Sep 2008 22:03:11 +0200
Message-ID: <20080925200311.GA4582@dose.home.local>
References: <20080924080546.GA21108@x61> <200809242113.52256.rjw@sisk.pl> <20080924194906.GA25874@x61> <200809242310.23477.rjw@sisk.pl> <20080925194253.GA2783@dose.home.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from eazy.amigager.de ([213.239.192.238]:53837 "EHLO
	eazy.amigager.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753389AbYIYUCI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Sep 2008 16:02:08 -0400
Content-Disposition: inline
In-Reply-To: <20080925194253.GA2783@dose.home.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I just found a method how I can enable WOL again:

echo enabled >
/sys/devices/pci0000:00/0000:00:1c.0/0000:01:00.0/power/wakeup

This device is the NIC device, of cause.

I already had another case (EHCI) where I needed to do this to be able
to wake the computer up with the USB keyboard. It seems like 2.6.27
behaves different here compared to 2.6.26, and things that worked with
2.6.26 need manual fixing to work again. Or did I make something wrong?

Regards,
Tino
