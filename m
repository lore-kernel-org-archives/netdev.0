From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/3] [SCTP] Prevent OOPS if hmac modules didn't load
Date: Wed, 09 May 2007 13:50:54 -0700 (PDT)
Message-ID: <20070509.135054.16514387.davem@davemloft.net>
References: <11787398302375-git-send-email-vladislav.yasevich@hp.com>
	<11787398301465-git-send-email-vladislav.yasevich@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, lksctp-developers@lists.sourceforge.net
To: vladislav.yasevich@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40495
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754059AbXEIUux (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 May 2007 16:50:53 -0400
In-Reply-To: <11787398301465-git-send-email-vladislav.yasevich@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Vlad Yasevich <vladislav.yasevich@hp.com>
Date: Wed,  9 May 2007 15:43:48 -0400

> SCTP was checking for NULL when trying to detect hmac
> allocation failure where it should have been using IS_ERR.
> Also, print a rate limited warning to the log telling the
> user what happend.
> 
> Signed-off-by: Vlad Yasevich <vladislav.yasevich@hp.com>

Applied, thanks Vlad.
