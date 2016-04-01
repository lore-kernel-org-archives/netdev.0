From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [Odd commit author id merge via netdev]
Date: Fri, 01 Apr 2016 22:01:44 +0200
Message-ID: <1459540904.3342.2.camel@sipsolutions.net>
References: <56FEB50E.4060004@oracle.com>
	 (sfid-20160401_195127_367731_49036B1D)
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: santosh shilimkar <santosh.shilimkar@oracle.com>,
	netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:52110 "EHLO sipsolutions.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751714AbcDAUBs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 1 Apr 2016 16:01:48 -0400
In-Reply-To: <56FEB50E.4060004@oracle.com> (sfid-20160401_195127_367731_49036B1D)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2016-04-01 at 10:51 -0700, santosh shilimkar wrote:
> Hi Dave,
> 
> I noticed something odd while checking the recent
> commits of mine in kernel.org tree made it via netdev.
> 
> Don't know if its patchwork tool doing this.
> Usual author line in my git objects	:
> 	Author: Santosh Shilimkar <emaid-id>
> 
> But the commits going via your tree seems to be like below..
> 	Author: email-id <email-id>
> 
> Few more examples of the commits end of the email. Can this
> be fixed for future commits ? The git objects you pulled from
> my tree directly have right author format where as ones which
> are picked from patchworks seems to be odd.
> 

Patchwork does store this info somehow and re-use it, quite possibly
from the very first patch you ever sent. I think this bug was *just*
fixed in patchwork, but it'll probably be a while until that fix lands.

However, you can go and create a patchwork account with the real name,
associate it with all the email addresses you use and then I think
it'll pick it up. Not entirely sure though, you'll have to test it.

johannes
