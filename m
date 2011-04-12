From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH] ethtool: time to blink provided in
 seconds not jiffies
Date: Tue, 12 Apr 2011 13:47:51 -0700 (PDT)
Message-ID: <20110412.134751.226779885.davem@davemloft.net>
References: <20110411230159.6727.91380.stgit@gitlad.jf.intel.com>
	<1302566234.5282.581.camel@localhost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bruce.w.allan@intel.com, netdev@vger.kernel.org
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48613
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932382Ab1DLUs1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Apr 2011 16:48:27 -0400
In-Reply-To: <1302566234.5282.581.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Tue, 12 Apr 2011 00:57:14 +0100

> On Mon, 2011-04-11 at 16:01 -0700, Bruce Allan wrote:
>> When blinking for a duration set by the user, the value specified is in
>> seconds but it is used as the number of jiffies in the timeout after which
>> the Physical ID indicator is deactivated.  Fix by converting the timeout
>> to seconds.
> 
> D'oh.
> 
>> Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
> Acked-by: Ben Hutchings <bhutchings@solarflare.com>

Applied, thanks.
