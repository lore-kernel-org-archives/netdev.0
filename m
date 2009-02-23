From: David Miller <davem@davemloft.net>
Subject: Re: net: amend the fix for SO_BSDCOMPAT gsopt infoleak
Date: Mon, 23 Feb 2009 15:38:59 -0800 (PST)
Message-ID: <20090223.153859.265316948.davem@davemloft.net>
References: <20090223164112.GA29425@kernel.sg>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	mpatocka@redhat.com
To: eugeneteo@kernel.sg
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53726
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752370AbZBWXjT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Feb 2009 18:39:19 -0500
In-Reply-To: <20090223164112.GA29425@kernel.sg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eugene Teo <eugeneteo@kernel.sg>
Date: Tue, 24 Feb 2009 00:41:12 +0800

> The fix for CVE-2009-0676 (upstream commit df0bca04) is incomplete. Note
> that the same problem of leaking kernel memory will reappear if someone
> on some architecture uses struct timeval with some internal padding (for
> example tv_sec 64-bit and tv_usec 32-bit) --- then, you are going to
> leak the padded bytes to userspace.
> 
> Signed-off-by: Eugene Teo <eugeneteo@kernel.sg>
> Reported-by: Mikulas Patocka <mpatocka@redhat.com>

Applied and queued up for -stable, thanks Eugene.
