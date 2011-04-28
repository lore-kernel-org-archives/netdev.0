From: DMITRIY GRUZMAN <xmb836@motorola.com>
Subject: usbnet: why is by default dev->rx_urb_size equal to dev->hard_mtu?
Date: Thu, 28 Apr 2011 18:00:12 -0500
Message-ID: <BANLkTim-h9F93D7xk1sHuEzfrzbgMCgFgQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from exprod5og115.obsmtp.com ([64.18.0.246]:55235 "EHLO
	exprod5og115.obsmtp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756539Ab1D1X1e (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Apr 2011 19:27:34 -0400
Received: from DE01MGRG01.AM.MOT-MOBILITY.COM ([10.176.129.42])
	by DE01MGRG01.AM.MOT-MOBILITY.COM (8.14.3/8.14.3) with ESMTP id p3SN0erk016960
	for <netdev@vger.kernel.org>; Thu, 28 Apr 2011 19:00:40 -0400 (EDT)
Received: from mail-gw0-f42.google.com (mail-gw0-f42.google.com [74.125.83.42])
	by DE01MGRG01.AM.MOT-MOBILITY.COM (8.14.3/8.14.3) with ESMTP id p3SMx5cu016289
	(version=TLSv1/SSLv3 cipher=RC4-MD5 bits=128 verify=OK)
	for <netdev@vger.kernel.org>; Thu, 28 Apr 2011 19:00:40 -0400 (EDT)
Received: by mail-gw0-f42.google.com with SMTP id 17so1620814gwb.15
        for <netdev@vger.kernel.org>; Thu, 28 Apr 2011 16:00:13 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

Currently, usbnet_probe() in drivers/net/usb/usbnet.c driver sets
dev->rx_urb_size equal to dev->hard_mtu unless the dev->rx_urb size is
previously set in the bind() call.  I do not think that there is any
correlation between those values and I think that setting
dev->rx_urb_size to dev->maxpacket would be more appropriate.

Please provide your comments so I know if I should proceed with making
such a change.

Thanks,

Dmitriy Gruzman
