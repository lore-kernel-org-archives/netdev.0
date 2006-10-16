From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: Re: Suppress / delay SYN-ACK
Date: Mon, 16 Oct 2006 09:02:12 +0200
Message-ID: <20061016070212.GB22667@xi.wantstofly.org>
References: <000101c6edd5$a880d430$1a04010a@V505CP>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from alephnull.demon.nl ([83.160.184.112]:9628 "EHLO
	xi.wantstofly.org") by vger.kernel.org with ESMTP id S1030311AbWJPHCO
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 16 Oct 2006 03:02:14 -0400
To: Martin Schiller <mschiller@tdt.de>
Content-Disposition: inline
In-Reply-To: <000101c6edd5$a880d430$1a04010a@V505CP>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Oct 12, 2006 at 10:08:53AM +0200, Martin Schiller wrote:

> I'm searching for a solution to suppress / delay the SYN-ACK packet of a
> listening server (-application) until he has decided (e.g. analysed the
> requesting ip-address or checked if the corresponding other end of a
> connection is available) if he wants to accept the connect request of the
> client. If not, it should be possible to reject the connect request.

I wrote something like this a couple of years ago:

	http://marc.theaimsgroup.com/?l=linux-netdev&m=103666165629419&w=2
	http://marc.theaimsgroup.com/?l=linux-netdev&m=106089519611631&w=2

There wasn't a whole lot of external interest, and my need for it
disappeared, so I never really finished it, and there's a couple of
unfixed bugs,


cheers,
Lennert
