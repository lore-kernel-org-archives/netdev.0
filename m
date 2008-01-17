From: jamal <hadi@cyberus.ca>
Subject: Re: [RFC][PATCH] Fixing SA/SP dumps on netlink/af_key
Date: Wed, 16 Jan 2008 20:39:40 -0500
Message-ID: <1200533980.4451.100.camel@localhost>
References: <E1JFHDM-00010A-00@gondolin.me.apana.org.au>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: timo.teras@iki.fi, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from py-out-1112.google.com ([64.233.166.183]:1899 "EHLO
	py-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752092AbYAQBjq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Jan 2008 20:39:46 -0500
Received: by py-out-1112.google.com with SMTP id u52so680408pyb.10
        for <netdev@vger.kernel.org>; Wed, 16 Jan 2008 17:39:43 -0800 (PST)
In-Reply-To: <E1JFHDM-00010A-00@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2008-17-01 at 09:58 +1100, Herbert Xu wrote:

> IMHO doing significant work on af_key is a waste of time.  It has no
> advantages at all over xfrm_user since neither is portable.  So we
> should discourage people from using af_key wherever possible.

I wouldnt disagree except some apps like racoon which depend on pfkey
are unfortunately beyond repair. Timo has a pretty good handle on the
issue from what i have seen so far, so it pretty much seems to be there
without significant changes (if the two issues are separated).

cheers,
jamal



