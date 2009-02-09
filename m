From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] gianfar: Fix boot hangs while bringing up gianfar
 ethernet
Date: Mon, 09 Feb 2009 14:58:52 -0800 (PST)
Message-ID: <20090209.145852.156568866.davem@davemloft.net>
References: <20090207225555.GA2680@ami.dom.local>
	<20090209172216.GA11312@ovro.caltech.edu>
	<20090209193440.GA2537@ami.dom.local>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, iws@ovro.caltech.edu, jacmet@sunsite.dk,
	dai.haruki@freescale.com, afleming@freescale.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: jarkao2@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43505
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751235AbZBIW66 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Feb 2009 17:58:58 -0500
In-Reply-To: <20090209193440.GA2537@ami.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jarek Poplawski <jarkao2@gmail.com>
Date: Mon, 9 Feb 2009 20:34:40 +0100

> gianfar: Fix boot hangs while bringing up gianfar ethernet
> 
> Ira Snyder found that commit 8c7396aebb68994c0519e438eecdf4d5fa9c7844
> "gianfar: Merge Tx and Rx interrupt for scheduling clean up ring" can
> cause hangs. It's because there was removed clearing of interrupts in
> gfar_schedule_cleanup() (which is called by an interrupt handler) in
> case when netif scheduling has been disabled. This patch brings back
> this action and a comment.
> 
> Reported-by: Ira Snyder <iws@ovro.caltech.edu>
> Reported-by: Peter Korsgaard <jacmet@sunsite.dk>
> Bisected-by: Ira Snyder <iws@ovro.caltech.edu>
> Tested-by: Peter Korsgaard <jacmet@sunsite.dk>
> Tested-by: Ira Snyder <iws@ovro.caltech.edu>
> Signed-by: Jarek Poplawski <jarkao2@gmail.com>

Applied, thanks everyone.
