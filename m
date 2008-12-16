From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tlan: Fix small (< 64 bytes) datagram transmissions
Date: Tue, 16 Dec 2008 01:44:43 -0800 (PST)
Message-ID: <20081216.014443.107697883.davem@davemloft.net>
References: <1229412425-2619-1-git-send-email-sakari.ailus@iki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: sakari.ailus@iki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41639
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751920AbYLPJom (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Dec 2008 04:44:42 -0500
In-Reply-To: <1229412425-2619-1-git-send-email-sakari.ailus@iki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sakari Ailus <sakari.ailus@iki.fi>
Date: Tue, 16 Dec 2008 09:27:05 +0200

> The TLAN chip does not support tranmissions smaller than 64 bytes. Smaller
> transfers need to be padded up to that size. This was broken by commit id
> 41873e9aff0632d80c74380d58a89e8d420151bd.
> 
> <URL:http://bugzilla.kernel.org/show_bug.cgi?id=11754>
> 
> Signed-off-by: Sakari Ailus <sakari.ailus@iki.fi>

Applied, thanks Sakari.

An example of the evil of "compile tested" changes that modify how a
chip is programmed :)
