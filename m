From: David Miller <davem@davemloft.net>
Subject: Re: [Resend v2 PATCH 2/3] TCP: options clean up
Date: Sat, 19 Jul 2008 00:06:41 -0700 (PDT)
Message-ID: <20080719.000641.12271128.davem@davemloft.net>
References: <396556a20805301217k293e5718h6bbf02bfe069022@europa>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: agl@imperialviolet.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60545
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751282AbYGSHGl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 19 Jul 2008 03:06:41 -0400
In-Reply-To: <396556a20805301217k293e5718h6bbf02bfe069022@europa>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Adam Langley" <agl@imperialviolet.org>
Date: Thu, 17 Jul 2008 16:08:10 -0700

> This should fix the following bugs:
>   * Connections with MD5 signatures produce invalid packets whenever SACK
>     options are included
>   * MD5 signatures are counted twice in the MSS calculations
> 
> Behaviour changes:
>   * A SYN with MD5 + SACK + TS elicits a SYNACK with MD5 + SACK
> 
>     This is because we can't fit any SACK blocks in a packet with MD5 + TS
>     options. There was discussion about disabling SACK rather than TS in
>     order to fit in better with old, buggy kernels, but that was deemed to
>     be unnecessary.
> 
>   * SYNs with MD5 don't include a TS option
> 
>     See above.
> 
> Additionally, it removes a bunch of duplicated logic for calculating options,
> which should help avoid these sort of issues in the future.
> 
> Signed-off-by: Adam Langley <agl@imperialviolet.org>

Applied.
