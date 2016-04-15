From: Holger Schurig <holgerschurig@gmail.com>
Subject: Re: [PATCH net-next V3 00/16] net: fec: cleanup and fixes
Date: Fri, 15 Apr 2016 10:33:37 +0200
Message-ID: <87bn5bp8ym.fsf@gmail.com>
References: <1459909562-22865-1-git-send-email-troy.kisky@boundarydevices.com>
	<87h9f4ebvp.fsf@gmail.com> <570FB998.2080900@boundarydevices.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org, davem@davemloft.net, fugang.duan@nxp.com,
	lznuaa@gmail.com, andrew@lunn.ch, stillcompiling@gmail.com,
	arnd@arndb.de, sergei.shtylyov@cogentembedded.com,
	gerg@uclinux.org, fabio.estevam@nxp.com, johannes@sipsolutions.net,
	l.stach@pengutronix.de, linux-arm-kernel@lists.infradead.org,
	tremyfr@gmail.com
To: Troy Kisky <troy.kisky@boundarydevices.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:36212 "EHLO
	mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752918AbcDOIdl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Apr 2016 04:33:41 -0400
Received: by mail-wm0-f66.google.com with SMTP id l6so4071683wml.3
        for <netdev@vger.kernel.org>; Fri, 15 Apr 2016 01:33:41 -0700 (PDT)
In-Reply-To: <570FB998.2080900@boundarydevices.com> (Troy Kisky's message of
	"Thu, 14 Apr 2016 08:39:04 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> I think I've already fixed this, but I've only submitted once.
>
> commit 466cb4a2e5583d2e18470f30d5948edcf4b947f5
> Author: Troy Kisky <troy.kisky@boundarydevices.com>
> Date:   Wed Jan 20 12:52:10 2016 -0700
>
>     net: fec: update dirty_tx even if no skb
>
>     If dirty_tx isn't updated, then dma_unmap_single
>     will be called twice.
>
>     Signed-off-by: Troy Kisky <troy.kisky@boundarydevices.com>

Thanks!   This fixed the issue.  Have a

Tested-by: <holgerschurig@gmail.com>
