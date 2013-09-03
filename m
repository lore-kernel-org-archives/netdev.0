From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH net-next 1/2] net: introduce generic net_random_N helper
Date: Tue, 03 Sep 2013 04:00:45 -0700
Message-ID: <1378206045.2048.9.camel@joe-AO722>
References: <1378204010-27050-1-git-send-email-dborkman@redhat.com>
	 <1378204010-27050-2-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	Theodore Ts'o <tytso@mit.edu>
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:36978 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752699Ab3ICLAr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Sep 2013 07:00:47 -0400
In-Reply-To: <1378204010-27050-2-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-09-03 at 12:26 +0200, Daniel Borkmann wrote:
> We have implemented the same function over and over, so introduce a
> generic helper net_random_N() that unifies these implementations.
> It internally used net_random() which eventually resolves to
> prandom_u32(). Explicit include of reciprocal_div.h is not necessary.

Perhaps adding a generic helper to random.h like
	u32 prandom_u32_between(u32 low, u32 high);
or
	u32 prandom_u32_range(u32 bound1, u32 bound2)
would be better.
