From: Oliver Neukum <oneukum@suse.com>
Subject: NAPI on USB network drivers
Date: Wed, 25 Jan 2017 10:34:41 +0100
Message-ID: <1485336881.16604.2.camel@suse.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-usb@vger.kernel.org
To: Hayes Wang <hayeswang@realtek.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:45706 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751594AbdAYJe5 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 25 Jan 2017 04:34:57 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

looking at r8152 I noticed that it uses NAPI. I never considered
this for the generic USB networking code as you cannot disable
interrupts for USB. Is it still worth it? What are the benefits?

	Regards
		Oliver
