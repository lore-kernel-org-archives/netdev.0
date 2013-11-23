From: Guenter Roeck <linux@roeck-us.net>
Subject: [PATCH 0/5] net: hwmon fixes
Date: Fri, 22 Nov 2013 22:07:56 -0800
Message-ID: <1385186881-7931-1-git-send-email-linux@roeck-us.net>
Cc: "David S. Miller" <davem@davemloft.net>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Bruce Allan <bruce.w.allan@intel.com>,
	Carolyn Wyborny <carolyn.wyborny@intel.com>,
	Don Skidmore <donald.c.skidmore@intel.com>,
	Greg Rose <gregory.v.rose@intel.com>,
	Nithin Nayak Sujir <nsujir@broadcom.com>,
	Michael Chan <mchan@broadcom.com>,
	e1000-devel@lists.sourceforge.net, lm-sensors@lm-sensors.org,
	Guenter Roeck <linux@roeck-us.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f43.google.com ([209.85.160.43]:57479 "EHLO
	mail-pb0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750851Ab3KWGIO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 Nov 2013 01:08:14 -0500
Received: by mail-pb0-f43.google.com with SMTP id rq2so2346148pbb.30
        for <netdev@vger.kernel.org>; Fri, 22 Nov 2013 22:08:14 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The hwmon subsystem is used by various network drivers to report temperature
sensor and other information. Unfortunately, its use is often not correct.
Typical errors are that the mandatory name sysfs attribute is not created,
that the temperature sensor index starts with 0 instead of 1, and/or that
sysfs attributes are created after the hwmon device was created.
The following sequence of patches fixes most of the problems.

The igb patches have been tested with real hardware; the others are compile
tested only.
