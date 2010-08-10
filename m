From: Marc Haber <mh+linux-kernel@zugschlus.de>
Subject: Re: e1000e crashes with 2.6.34.x and ThinkPad T60
Date: Tue, 10 Aug 2010 14:04:58 +0200
Message-ID: <20100810120458.GB21511@torres.zugschlus.de>
References: <20100724092644.GA13353@torres.zugschlus.de> <EA929A9653AAE14F841771FB1DE5A1366000F42E28@rrsmsx501.amr.corp.intel.com> <20100730125452.GA21444@torres.zugschlus.de> <EA929A9653AAE14F841771FB1DE5A13660024083FE@rrsmsx501.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Marc Haber <mh+linux-kernel@zugschlus.de>,
	Linux Kernel Developers <linux-kernel@vger.kernel.org>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	"Allan, Bruce W" <bruce.w.allan@intel.com>
To: "Tantilov, Emil S" <emil.s.tantilov@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from torres.zugschlus.de ([85.214.131.164]:48933 "EHLO
	torres.zugschlus.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756524Ab0HJME7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Aug 2010 08:04:59 -0400
Content-Disposition: inline
In-Reply-To: <EA929A9653AAE14F841771FB1DE5A13660024083FE@rrsmsx501.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 04, 2010 at 12:23:45PM -0600, Tantilov, Emil S wrote:
> Looking at your lspci output - your system has a slightly different HW, but I don't know if this is significant.
> 
> Are you loading the kernel with any parameters (cat /proc/cmdline)?

BOOT_IMAGE=/vmlinuz-2.6.35-zgws1 root=/dev/mapper/root ro
resume=/dev/mapper/swap0 quiet splash radeon.modeset=1

> Do you have firewall configured (iptables -L)?

I am working pretty intensively with virtual machines which are natted
here and there. I have a handful of MASQUERADE rules in the
nat/POSTROUTING chain, but that's it.

> Also now that 2.6.35 is out - could you give it a try and see if the situation had improved?

Tried, no improvement.

Greetings
Marc

-- 
-----------------------------------------------------------------------------
Marc Haber         | "I don't trust Computers. They | Mailadresse im Header
Mannheim, Germany  |  lose things."    Winona Ryder | Fon: *49 621 72739834
Nordisch by Nature |  How to make an American Quilt | Fax: *49 3221 2323190
