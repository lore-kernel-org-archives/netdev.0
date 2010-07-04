From: LionSky <loverunning2@gmail.com>
Subject: How to detect ethernet cable plug in event when ethernet card is in
	D3hot power state?
Date: Sun, 4 Jul 2010 16:50:58 +0800
Message-ID: <AANLkTinPgkwdrn-CYfEuyXc8mrHElSw1ecJojMY82Qbd@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qw0-f46.google.com ([209.85.216.46]:52862 "EHLO
	mail-qw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756299Ab0GDIu7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 4 Jul 2010 04:50:59 -0400
Received: by qwh6 with SMTP id 6so523920qwh.19
        for <netdev@vger.kernel.org>; Sun, 04 Jul 2010 01:50:58 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Just as the title.
A scenario is as follows:
When the cable is unplug-in, the ethernet card is placed into D3hot
power state for power saving.
When the cable is plug in later, it will be resumed back to D0 for user usage.

But I do not know whether the ethernet driver/OS can detect the cable
plug-in event when ethernet card is at D3hot power state?
 If it can do that, OS can resume it from D3 to D0.  Thanks
