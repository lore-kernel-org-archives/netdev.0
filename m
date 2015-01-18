From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net: sctp: fix race for one-to-many sockets in
 sendmsg's auto associate
Date: Sat, 17 Jan 2015 23:53:54 -0500 (EST)
Message-ID: <20150117.235354.784017919774639035.davem@davemloft.net>
References: <1421336075-25061-1-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: vyasevich@gmail.com, netdev@vger.kernel.org,
	linux-sctp@vger.kernel.org
To: dborkman@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42219 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751412AbbAREx4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 17 Jan 2015 23:53:56 -0500
In-Reply-To: <1421336075-25061-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <dborkman@redhat.com>
Date: Thu, 15 Jan 2015 16:34:35 +0100

 ...
> The fix defers waiting after sctp_primitive_ASSOCIATE() and
> sctp_primitive_SEND() succeeded, so that DATA chunks cooked up
> from sctp_sendmsg() have already been placed into the output
> queue through the side-effect interpreter, and therefore can then
> be bundeled together with COOKIE_ECHO control chunks.
 ...
> Looks like this bug is from the pre-git history museum. ;)
> 
> Fixes: 08707d5482df ("lksctp-2_5_31-0_5_1.patch")
> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>

Applied, thanks.
