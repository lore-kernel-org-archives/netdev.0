From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] corrected documentation for hardware time stamping
Date: Wed, 07 Apr 2010 21:53:01 -0700 (PDT)
Message-ID: <20100407.215301.154186846.davem@davemloft.net>
References: <4BBC6944.2090102@OEAW.ac.at>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, patrick.ohly@gmx.de
To: loschmidt@fiss-oeaw.at, Patrick.Loschmidt@OEAW.ac.at
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40873
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750831Ab0DHEw6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Apr 2010 00:52:58 -0400
In-Reply-To: <4BBC6944.2090102@OEAW.ac.at>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Patrick Loschmidt <Patrick.Loschmidt@OEAW.ac.at>
Date: Wed, 07 Apr 2010 13:15:16 +0200

> From: Patrick Loschmidt <Patrick.Loschmidt@oeaw.ac.at>
> 
> The current documentation for hardware time stamping does not correctly specify the available kernel
> functions since the implementation was changed later on.
> 
> Signed-off-by: Patrick Loschmidt <Patrick.Loschmidt@oeaw.ac.at>

Applied thanks.

> --- Documentation/networking/timestamping.txt.orig	2010-04-07 12:52:47.000000000 +0200
> +++ Documentation/networking/timestamping.txt	2010-04-07 11:43:57.000000000 +0200

Please "-p1" base your patches in the future.

>  	/* PTP v1, UDP, any kind of event packet */
>  	HWTSTAMP_FILTER_PTP_V1_L4_EVENT,
> -
> -        ...
> +	

That line has extraneous trailing whitespace which I needed
to fix up when applying your patch.

Please attend to these details properly in future patch
submissions, as it will save me a lot of time.

Thanks.
