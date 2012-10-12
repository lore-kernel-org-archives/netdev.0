From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] bridge: don't flood multicast packets if no snooping
 entry
Date: Fri, 12 Oct 2012 09:48:52 +0800
Message-ID: <20121012014852.GA17025@gondor.apana.org.au>
References: <1350004643-3786-1-git-send-email-minggr@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Lin Ming <minggr@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sting.hengli.com.au ([178.18.18.71]:42493 "EHLO
	fornost.hengli.com.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755457Ab2JLBsy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Oct 2012 21:48:54 -0400
Content-Disposition: inline
In-Reply-To: <1350004643-3786-1-git-send-email-minggr@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Oct 12, 2012 at 09:17:23AM +0800, Lin Ming wrote:
> From: Lin Ming <mlin@ss.pku.edu.cn>
> 
> Currently, multicast packets will be flood even if there is no
> mutlicast snooping entry attached to port.
> 
> With IGMP snooping enabled, we should stop sending multicast packets
> if there is no member joined.

Hmm, the default is deliberately this way so that we don't disrupt
traffic when we boot up.  If you want to stop flooding unknown groups
by default you have to make it an option.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
