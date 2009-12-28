From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/3] phylib: Fix deadlock on resume
Date: Sun, 27 Dec 2009 21:54:54 -0800 (PST)
Message-ID: <20091227.215454.226776048.davem@davemloft.net>
References: <20091222221447.GA9268@oksana.dev.rtsoft.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: afleming@freescale.com, leoli@freescale.com,
	netdev@vger.kernel.org, linuxppc-dev@ozlabs.org,
	linux-pm@lists.linux-foundation.org
To: cbouatmailru@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45876
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750975AbZL1Fyy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Dec 2009 00:54:54 -0500
In-Reply-To: <20091222221447.GA9268@oksana.dev.rtsoft.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Anton Vorontsov <cbouatmailru@gmail.com>
Date: Wed, 23 Dec 2009 01:14:47 +0300

> Sometimes kernel hangs on resume with the following trace:
 ...
> This patch fixes the issue by stopping the state machine on suspend
> and starting it again on resume.
> 
> Signed-off-by: Anton Vorontsov <avorontsov@ru.mvista.com>

Applied.
