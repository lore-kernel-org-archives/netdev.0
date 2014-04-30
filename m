From: Wei Liu <wei.liu2@citrix.com>
Subject: Re: [PATCH V7 net-next] xen-net{back,front}: Multiple transmit and
 receive queues
Date: Wed, 30 Apr 2014 15:50:19 +0100
Message-ID: <20140430145019.GC19082@zion.uk.xensource.com>
References: <1398778035-26233-1-git-send-email-andrew.bennieston@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <xen-devel@lists.xenproject.org>, <davem@davemloft.net>,
	<ian.campbell@citrix.com>, <wei.liu2@citrix.com>,
	<paul.durrant@citrix.com>, <netdev@vger.kernel.org>,
	<david.vrabel@citrix.com>, <zoltan.kiss@citrix.com>
To: "Andrew J. Bennieston" <andrew.bennieston@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:21009 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1422648AbaD3OuV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Apr 2014 10:50:21 -0400
Content-Disposition: inline
In-Reply-To: <1398778035-26233-1-git-send-email-andrew.bennieston@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 29, 2014 at 02:27:08PM +0100, Andrew J. Bennieston wrote:
[...]
> 
> V7:
> - Rebase on latest net-next, which includes the netback grant mapping
>   patch series from Zoltan Kiss
> - Reduce QUEUE_NAME_SIZE by 1 to avoid double-counting the trailing '\0'
> - Simplify the queue hashing by using (hash % num_queues) instead of
>   multiply & shift.
> - Add ratelimited warning for invalid queue selection.
> - Fix error handling to correctly tear down already setup queues.

I presume this is a fix to the bug discoverd by Sander?

Wei.
