From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [patch] isdn: use strlcpy() instead strcpy()
Date: Mon, 16 Dec 2013 05:43:38 -0800
Message-ID: <1387201418.19078.225.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20131216094626.GC13831@elgon.mountain>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Karsten Keil <isdn@linux-pingi.de>, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: Dan Carpenter <dan.carpenter@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:47275 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753570Ab3LPNnk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Dec 2013 08:43:40 -0500
In-Reply-To: <20131216094626.GC13831@elgon.mountain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2013-12-16 at 12:46 +0300, Dan Carpenter wrote:
> I don't think the in-kernel drivers ever hit this strcpy() so this
> doesn't change how the code works.  But strcpy() is safer.
> 

strcpy() is safer ?

-ENOPARSE ...
