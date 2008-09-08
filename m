From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bnx2x: EEH recovery fix
Date: Mon, 08 Sep 2008 12:47:43 -0700 (PDT)
Message-ID: <20080908.124743.30466861.davem@davemloft.net>
References: <BD3F7F1EFBA6D54DB056C4FFA45140080334A46036@SJEXCHCCR01.corp.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, yitchak.gertner@broadcom.com
To: eilong@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41637
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753016AbYIHTrv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Sep 2008 15:47:51 -0400
In-Reply-To: <BD3F7F1EFBA6D54DB056C4FFA45140080334A46036@SJEXCHCCR01.corp.ad.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Eilon Greenstein" <eilong@broadcom.com>
Date: Mon, 8 Sep 2008 03:22:32 -0700

> The EEH mechanism caused a fatal error when using the bnx2x since
> the driver attempted accessing the device after it was reset by the
> EEH. This patch sets a proper unload when EEH error is detected
> without accessing the device.
>
> Since the current implementation causes a fatal error, I ask that
> you will consider applying this patch.

What user has run into and reported this failure, and is it
a regression compared to 2.6.26?

That is the criteria for my putting this patch in now.

Since EEH triggers are an exceedingly corner case error condition,
this puts this patch even less valid to go in outside of the merge
window.
