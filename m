From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: sock: make sock_tx_timestamp void
Date: Sun, 14 Apr 2013 15:43:40 -0400 (EDT)
Message-ID: <20130414.154340.1700559336419380211.davem@davemloft.net>
References: <cover.1365962139.git.dborkman@redhat.com>
	<2856df883c4653d360c44718151f37682621b577.1365962139.git.dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dborkman@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48540 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932356Ab3DNTnl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 14 Apr 2013 15:43:41 -0400
In-Reply-To: <2856df883c4653d360c44718151f37682621b577.1365962139.git.dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <dborkman@redhat.com>
Date: Sun, 14 Apr 2013 20:08:13 +0200

> Currently, sock_tx_timestamp() always returns 0. The comment that
> describes the sock_tx_timestamp() function wrongly says that it
> returns an error when an invalid argument is passed (from commit
> 20d4947353be, ``net: socket infrastructure for SO_TIMESTAMPING'').
> Make the function void, so that we can also remove all the unneeded
> if conditions that check for such a _non-existant_ error case in the
> output path.
> 
> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>

Applied.
