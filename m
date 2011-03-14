From: David Miller <davem@davemloft.net>
Subject: Re: [GIT/PATCH v5] xen network backend driver
Date: Mon, 14 Mar 2011 13:23:55 -0700 (PDT)
Message-ID: <20110314.132355.226777213.davem@davemloft.net>
References: <1300112879.17339.2162.camel@zakaz.uk.xensource.com>
	<1300128035.2584.6.camel@bwh-desktop>
	<1300131040.32696.23.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bhutchings@solarflare.com, netdev@vger.kernel.org,
	xen-devel@lists.xensource.com, jeremy@goop.org,
	herbert@gondor.apana.org.au, konrad.wilk@oracle.com,
	romieu@fr.zoreil.com, shemminger@vyatta.com, mirqus@gmail.com
To: Ian.Campbell@eu.citrix.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41052
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751987Ab1CNUXR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Mar 2011 16:23:17 -0400
In-Reply-To: <1300131040.32696.23.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ian Campbell <Ian.Campbell@eu.citrix.com>
Date: Mon, 14 Mar 2011 19:30:40 +0000

> On Mon, 2011-03-14 at 18:40 +0000, Ben Hutchings wrote:
>> I know you have asked for this to be pulled, in order to retain its
>> history, but I'm not sure that David Miller will do this unless the
>> driver is at least buildable at each stage in the history.  (However,
>> given that the driver wouldn't be enabled before it's added, I'm not
>> sure it matters in this case.)
> 
> I think it should be, at least from the second commit onwards (modulo
> any mistakes made in the past).

I don't want to retain all of that history, there are so many broken
points in the history that the only thing you can do is go back and
add Kconfig commits to depend the driver upon BROKEN, and that in effect
changes the history devalueing it even further.

I just want one patch that adds the driver in it's most current state,
and that's all.

Thanks.
