From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH 1/2] bnx2: factor out gzip unpacker
Date: 21 Sep 2007 22:13:46 +0200
Message-ID: <p73ps0b93ph.fsf@bingen.suse.de>
References: <200709211201.24475.vda.linux@googlemail.com>
	<200709211803.55554.vda.linux@googlemail.com>
	<20070921.104912.41646795.davem@davemloft.net>
	<200709211905.23946.vda.linux@googlemail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, jeff@garzik.org,
	mchan@broadcom.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Denys Vlasenko <vda.linux@googlemail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns2.suse.de ([195.135.220.15]:59391 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1761455AbXIUUNt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 21 Sep 2007 16:13:49 -0400
In-Reply-To: <200709211905.23946.vda.linux@googlemail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Denys Vlasenko <vda.linux@googlemail.com> writes:
> 
> I plan to use gzip compression on following drivers' firmware,
> if patches will be accepted:
> 
>    text    data     bss     dec     hex filename
>   17653  109968     240  127861   1f375 drivers/net/acenic.o
>    6628  120448       4  127080   1f068 drivers/net/dgrs.o
>          ^^^^^^

Just change the makefiles to always install gzip'ed modules
modutils knows how to unzip them on the fly.

That will catch all the firmware and all the other code too.

-Andi
