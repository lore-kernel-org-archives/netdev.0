From: Timo Teras <timo.teras@iki.fi>
Subject: [PATCH 0/4] xfrm fixes and flow structurization
Date: Wed, 31 Mar 2010 13:17:02 +0300
Message-ID: <1270030626-16687-2-git-send-email-timo.teras@iki.fi>
References: <1270030626-16687-1-git-send-email-timo.teras@iki.fi>
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Timo Teras <timo.teras@iki.fi>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f220.google.com ([209.85.219.220]:34536 "EHLO
	mail-ew0-f220.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933195Ab0CaKRV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Mar 2010 06:17:21 -0400
Received: by ewy20 with SMTP id 20so1817152ewy.1
        for <netdev@vger.kernel.org>; Wed, 31 Mar 2010 03:17:20 -0700 (PDT)
In-Reply-To: <1270030626-16687-1-git-send-email-timo.teras@iki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

These are fixes and cleanups which should be good for merging in.
Patches 1 and 2 are new. Patches 3 and 4 were previously discussed
with Herbert.

Please review and consider committing.

Thanks.

Timo Teras (4):
  xfrm: increment genid before bumping state genids
  xfrm_user: verify policy direction at XFRM_MSG_POLEXPIRE handler
  xfrm: remove policy lock when accessing policy->walk.dead
  flow: structurize flow cache

 net/core/flow.c        |  223 +++++++++++++++++++++++++----------------------
 net/xfrm/xfrm_policy.c |   31 ++-----
 net/xfrm/xfrm_state.c  |    3 +-
 net/xfrm/xfrm_user.c   |   10 +-
 4 files changed, 135 insertions(+), 132 deletions(-)

