From: David Miller <davem@davemloft.net>
Subject: Re: IFF_RUNNING without carrier after reboot
Date: Sun, 14 Dec 2008 22:29:51 -0800 (PST)
Message-ID: <20081214.222951.190945313.davem@davemloft.net>
References: <1229225313.22285.151.camel@violet.holtmann.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: marcel@holtmann.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41573
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751237AbYLOG3t (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Dec 2008 01:29:49 -0500
In-Reply-To: <1229225313.22285.151.camel@violet.holtmann.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Marcel Holtmann <marcel@holtmann.org>
Date: Sun, 14 Dec 2008 04:28:33 +0100

> I have a really strange issue with the 2.6.28 kernel. So when I boot
> that kernel and then call "ifconfig eth0 up && ifconfig" it shows eth0
> with the flag RUNNING enabled. Even if no cable is plugged into that
> device.

The RUNNING state has no connection to link presence.

It just means that the device has been brought up by a
user configuration command like the ifconfig you ran.

It really means nothing else.
