From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] sctp: regression bug fixes
Date: Thu, 22 Jan 2009 14:53:37 -0800 (PST)
Message-ID: <20090122.145337.257123667.davem@davemloft.net>
References: <1232663768-4028-1-git-send-email-vladislav.yasevich@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org
To: vladislav.yasevich@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40212
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1758106AbZAVWxg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Jan 2009 17:53:36 -0500
In-Reply-To: <1232663768-4028-1-git-send-email-vladislav.yasevich@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vlad Yasevich <vladislav.yasevich@hp.com>
Date: Thu, 22 Jan 2009 17:36:04 -0500

> This is a set of bug fixes that address various regressions reported to
> the sctp list as well and to me privately.
> 
> Here is the list:
>     1) SCTP checksum produced wrong result on big endian arch.
>     2) Sometimes SCTP connection would hang withtout transmitting anything.
>        Sometimes it would fail to retrnasmit after the second loss.
>     3) The accept code raced with input processing resulting in locking the
>        wrong socket.
> 
> Please apply and push to stable.

All applied and queued up for -stable, thanks Vlad.
