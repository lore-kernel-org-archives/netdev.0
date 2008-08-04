From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] syncookies: free reqsk on xfrm_lookup error
Date: Sun, 03 Aug 2008 18:13:58 -0700 (PDT)
Message-ID: <20080803.181358.61761784.davem@davemloft.net>
References: <1217203435-18351-1-git-send-email-fw@strlen.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ggriffin.kernel@gmail.com
To: fw@strlen.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:32817
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753255AbYHDBN5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 3 Aug 2008 21:13:57 -0400
In-Reply-To: <1217203435-18351-1-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>
Date: Mon, 28 Jul 2008 02:03:55 +0200

> cookie_v6_check() did not call reqsk_free() if xfrm_lookup() fails,
> leaking the request sock.
> 
> Compile tested only.
> 
> Signed-off-by: Florian Westphal <fw@strlen.de>

Looks good, applied, thanks Florian.
