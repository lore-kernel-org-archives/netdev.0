From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] sky2: use new netdev_rss_key_fill() helper
Date: Wed, 19 Nov 2014 07:28:06 -0800
Message-ID: <1416410886.14060.48.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1416388011-10491-1-git-send-email-ipm@chirality.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Mirko Lindner <mlindner@marvell.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Eric Dumazet <edumazet@google.com>
To: Ian Morris <ipm@chirality.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f54.google.com ([209.85.220.54]:37059 "EHLO
	mail-pa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753865AbaKSP2I (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Nov 2014 10:28:08 -0500
Received: by mail-pa0-f54.google.com with SMTP id fb1so449978pad.13
        for <netdev@vger.kernel.org>; Wed, 19 Nov 2014 07:28:08 -0800 (PST)
In-Reply-To: <1416388011-10491-1-git-send-email-ipm@chirality.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2014-11-19 at 09:06 +0000, Ian Morris wrote:
> Switch to a random RSS key rather than a fixed one.
> Using netdev_rss_key_fill helper also ensures that all ports share
> a common key.
> 
> See also commit 960fb622f85180f36d3aff82af53e2be3db2f888.
> 
> Signed-off-by: Ian Morris <ipm@chirality.org.uk>
> Cc: Mirko Lindner <mlindner@marvell.com>
> Cc: Stephen Hemminger <stephen@networkplumber.org>
> Cc: Eric Dumazet <edumazet@google.com>
> ---
>  drivers/net/ethernet/marvell/sky2.c | 13 ++++---------
>  1 file changed, 4 insertions(+), 9 deletions(-)

Nice catch, this one escaped from my scan ;)

(Another one is in drivers/net/ethernet/cisco/enic/enic_main.c )

Acked-by: Eric Dumazet <edumazet@google.com>

Nit : When referring a commit, use 12 digit sha1 followed by patch
title.
In this particular case you could have say :

See also commit 960fb622f851 ("net: provide a per host RSS key generic
infrastructure").

Or something like that.

Thanks Ian !
