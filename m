From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] sctp: Set source addresses on the association before
 adding transports
Date: Fri, 13 Nov 2009 19:57:09 -0800 (PST)
Message-ID: <20091113.195709.164224314.davem@davemloft.net>
References: <1257879454-31661-1-git-send-email-vladislav.yasevich@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org
To: vladislav.yasevich@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35590
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757595AbZKND4x (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Nov 2009 22:56:53 -0500
In-Reply-To: <1257879454-31661-1-git-send-email-vladislav.yasevich@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vlad Yasevich <vladislav.yasevich@hp.com>
Date: Tue, 10 Nov 2009 13:57:34 -0500

> Recent commit 8da645e101a8c20c6073efda3c7cc74eec01b87f
> 	sctp: Get rid of an extra routing lookup when adding a transport
> introduced a regression in the connection setup.  The behavior was
> different between IPv4 and IPv6.  IPv4 case ended up working because the
> route lookup routing returned a NULL route, which triggered another
> route lookup later in the output patch that succeeded.  In the IPv6 case,
> a valid route was returned for first call, but we could not find a valid
> source address at the time since the source addresses were not set on the
> association yet.  Thus resulted in a hung connection.
> 
> The solution is to set the source addresses on the association prior to
> adding peers.
> 
> Signed-off-by: Vlad Yasevich <vladislav.yasevich@hp.com>

Applied.
