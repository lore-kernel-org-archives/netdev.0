From: Marcel Holtmann <marcel@holtmann.org>
Subject: IFF_RUNNING without carrier after reboot
Date: Sun, 14 Dec 2008 04:28:33 +0100
Message-ID: <1229225313.22285.151.camel@violet.holtmann.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from senator.holtmann.net ([87.106.208.187]:42693 "EHLO
	mail.holtmann.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753952AbYLND2m (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 13 Dec 2008 22:28:42 -0500
Received: from [192.168.1.42] (p5487FA02.dip.t-dialin.net [84.135.250.2])
	by mail.holtmann.org (Postfix) with ESMTP id 50817165E42
	for <netdev@vger.kernel.org>; Sun, 14 Dec 2008 04:28:41 +0100 (CET)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi guys,

I have a really strange issue with the 2.6.28 kernel. So when I boot
that kernel and then call "ifconfig eth0 up && ifconfig" it shows eth0
with the flag RUNNING enabled. Even if no cable is plugged into that
device.

If I then actually do plug on in and wait a few seconds (until the
lights blink) and then unplug everything is perfectly fine and it
behaves form there on normal

It is really only after boot and the 2.6.27 kernel behaves as expected.
Any ideas what's wrong here. My machine is an X61 laptop with e1000e
based Ethernet card.

Regards

Marcel


