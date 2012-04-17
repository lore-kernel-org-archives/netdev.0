From: Ian Campbell <Ian.Campbell@citrix.com>
Subject: In tree firmware not kept up to date
Date: Tue, 17 Apr 2012 16:11:44 +0100
Message-ID: <1334675504.23948.99.camel@zakaz.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Ian Jackson <Ian.Jackson@eu.citrix.com>,
	Michael Chan <mchan@broadcom.com>,
	David Miller <davem@davemloft.net>,
	Ben Hutchings <bhutchings@solarflare.com>
To: <netdev@vger.kernel.org>,
	linux-kernel <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.eu.citrix.com ([62.200.22.115]:52901 "EHLO
	SMTP.EU.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754675Ab2DQPLr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Apr 2012 11:11:47 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

What is the current policy wrt keeping the in-tree firmware updated
alongside the drivers?

I use CONFIG_FIRMWARE_IN_KERNEL but a couple of times[0] recently this
has failed me because the in-tree bnx2 driver requires
bnx2/bnx2-mips-09-6.2.1b.fw but the tree contains
firmware/bnx2/bnx2-mips-09-6.2.1a.fw.ihex and not 6.2.1b.

Is it a bug that bnx2 was updated without adding the new firmware or is
a bug that the obsolete firmware is still sitting in the tree?

Ian.

[0] It's possible the same thing and I've just tripped over it more than
once now.
