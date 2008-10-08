From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 2/2] sctp: shrink sctp_tsnmap some more by
 removing gabs array
Date: Wed, 08 Oct 2008 14:19:14 -0700 (PDT)
Message-ID: <20081008.141914.109425275.davem@davemloft.net>
References: <1223497670-519-1-git-send-email-vladislav.yasevich@hp.com>
	<1223497670-519-3-git-send-email-vladislav.yasevich@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org
To: vladislav.yasevich@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45006
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755085AbYJHVTi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Oct 2008 17:19:38 -0400
In-Reply-To: <1223497670-519-3-git-send-email-vladislav.yasevich@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vlad Yasevich <vladislav.yasevich@hp.com>
Date: Wed,  8 Oct 2008 16:27:50 -0400

> The gabs array in the sctp_tsnmap structure is only used
> in one place, sctp_make_sack().  As such, carrying the
> array around in the sctp_tsnmap and thus directly in
> the sctp_association is rather pointless since most
> of the time it's just taking up space.  Now, let
> sctp_make_sack create and populate it and then throw
> it away when it's done.
> 
> Signed-off-by: Vlad Yasevich <vladislav.yasevich@hp.com>

Applied.
