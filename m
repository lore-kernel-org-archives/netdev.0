From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: Re: [RFC] more robust inet range checking
Date: Wed, 10 Oct 2007 13:53:08 -0400
Message-ID: <470D1184.4020402@hp.com>
References: <20071010141530.GA10661@iris.sw.ru> <20071010100939.0783febb@freepuppy.rosehill>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Denis V. Lunev" <den@openvz.org>, davem@davemloft.net,
	aarapov@redhat.com, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from atlrel8.hp.com ([156.153.255.206]:43996 "EHLO atlrel8.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754547AbXJJRxL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 10 Oct 2007 13:53:11 -0400
In-Reply-To: <20071010100939.0783febb@freepuppy.rosehill>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Hemminger wrote:
> More complete version of local port range checking.
> 
> 1. Enforce that low < high when setting.
> 2. Use seqlock to ensure atomic update.
> 3. Add port randomization to SCTP. This is a new feature but
>    easier than maintaining old code that was broken if range
>    changed.
> 
> Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>
> 

Ack the SCTP portion.  Much nicer and a much needed improvement.

Thanks
-vlad
