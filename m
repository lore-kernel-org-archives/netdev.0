From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] asix: fix setting custom MAC address on Asix 88178
 devices
Date: Tue, 10 Jan 2012 15:00:51 -0800 (PST)
Message-ID: <20120110.150051.1786115333097978498.davem@davemloft.net>
References: <20120110164017.24658.9965.stgit@localhost6.localdomain6>
	<20120110164023.24658.76719.stgit@localhost6.localdomain6>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, grundler@chromium.org, allan@asix.com.tw
To: jussi.kivilinna@mbnet.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:47015 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933887Ab2AJXBE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Jan 2012 18:01:04 -0500
In-Reply-To: <20120110164023.24658.76719.stgit@localhost6.localdomain6>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jussi Kivilinna <jussi.kivilinna@mbnet.fi>
Date: Tue, 10 Jan 2012 18:40:23 +0200

> (Note: only compile tested, I don't have 88178 device to confirm that this
> patch works. Please, test.)
> 
> ---
> 
> In kernel v3.2 initialization sequence for Asix 88178 devices was changed so
> that hardware is reseted on every time interface is brought up (ifconfig up),
> instead just at USB probe time. This causes problem with setting custom MAC
> address to device as ax88178_reset causes reload of MAC address from EEPROM.
> 
> This patch fixes the issue by rewriting MAC address at end of ax88178_reset.
> 
> Signed-off-by: Jussi Kivilinna <jussi.kivilinna@mbnet.fi>
> Cc: Grant Grundler <grundler@chromium.org>
> Cc: Allan Chou <allan@asix.com.tw>
> Cc: stable <stable@vger.kernel.org>
> ---

Please do not format your commit messages like this, everything after
that first "---" will be stripped away.  So in this case if I applied
this email into GIT as-is we'd lose the actual commit message and
only have your "(Note: " thing.

I fixed this up and applied it with Grant's ACK.
