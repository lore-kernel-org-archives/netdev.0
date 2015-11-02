From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] af_unix: optimize unix_writable by inlining
Date: Mon, 02 Nov 2015 12:08:22 -0500 (EST)
Message-ID: <20151102.120822.1151065456395557870.davem@davemloft.net>
References: <1446483719-30310-1-git-send-email-aconole@bytheb.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: aconole@bytheb.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33491 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753257AbbKBRI0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Nov 2015 12:08:26 -0500
In-Reply-To: <1446483719-30310-1-git-send-email-aconole@bytheb.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Aaron Conole <aconole@bytheb.org>
Date: Mon,  2 Nov 2015 12:01:59 -0500

> unix_writable() originally was inlined, but was changed as part of
> commit 1586a5877db9 ("af_unix: do not report POLLOUT on
> listeners"). Re-enable the inline flag.
> 
> Signed-off-by: Aaron Conole <aconole@bytheb.org>

This is never appropriate.

The compiler should be fixed to inline functions properly when
appropriate for the optimization level requested.
