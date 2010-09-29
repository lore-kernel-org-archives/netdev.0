From: David Woodhouse <dwmw2@infradead.org>
Subject: Re: WiMAX linux firmware pull request
Date: Wed, 29 Sep 2010 11:52:48 +0900
Message-ID: <1285728768.814.74.camel@macbook.infradead.org>
References: <1285699570.3136.307.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: wimax@linuxwimax.org, netdev@vger.kernel.org
To: Inaky Perez-Gonzalez <inaky.perez-gonzalez@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([18.85.46.34]:58691 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751223Ab0I2Cwz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Sep 2010 22:52:55 -0400
In-Reply-To: <1285699570.3136.307.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2010-09-28 at 11:46 -0700, Inaky Perez-Gonzalez wrote:    
>    The 1.3 version is purged as it is not supported anymore.

Not supported by newer kernels? Or "if you are using something that
requires the 1.3 firmware, you can just fuck off and die", along the
lines of what we say to users of the 2.4 kernel?

We shouldn't drop stuff from linux-firmware.git until there really is
*no* reason to need it any more. We shouldn't force people to keep
linux-firmware in step with their kernel; they should always be able to
use the latest.

When I get home from Tokyo I'll be working on a way to specify min/max
kernel versions for each firmware image, along with a 'make install'
target which lets you say "drop anything which is only relevant to
kernels < 2.6.35' or whatever.

-- 
dwmw2

