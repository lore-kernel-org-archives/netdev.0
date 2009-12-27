From: Roel Kluin <roel.kluin@gmail.com>
Subject: Re: [PATCH] atarilance: timeout ignored in lance_open()
Date: Sun, 27 Dec 2009 15:09:03 +0100
Message-ID: <4B376A7F.9010805@gmail.com>
References: <4B37610F.8050401@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Roel Kluin <roel.kluin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ey-out-2122.google.com ([74.125.78.27]:5220 "EHLO
	ey-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751972AbZL0OGP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 27 Dec 2009 09:06:15 -0500
In-Reply-To: <4B37610F.8050401@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Op 27-12-09 14:28, Roel Kluin schreef:
> With `while (--limit > 0)' i reaches 0 after the loop, so upon timeout the
> error was not returned.
> 
> Signed-off-by: Roel Kluin <roel.kluin@gmail.com>
> ---
> diff --git a/drivers/net/niu.c b/drivers/net/niu.c

Oops, forgot to update the subject, please ignore, I'll send another.

Roel
