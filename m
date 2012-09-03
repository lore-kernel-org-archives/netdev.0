From: David Miller <davem@davemloft.net>
Subject: Re: [net-next.git 5/7] stmmac: add sysFs support
Date: Mon, 03 Sep 2012 13:20:30 -0400 (EDT)
Message-ID: <20120903.132030.45862101479511279.davem@davemloft.net>
References: <1346658422-1925-1-git-send-email-peppe.cavallaro@st.com>
	<1346658422-1925-6-git-send-email-peppe.cavallaro@st.com>
	<1346676267.7787.82.camel@deadeye.wl.decadent.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: peppe.cavallaro@st.com, netdev@vger.kernel.org
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48993 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753273Ab2ICRUf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Sep 2012 13:20:35 -0400
In-Reply-To: <1346676267.7787.82.camel@deadeye.wl.decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Mon, 3 Sep 2012 13:44:27 +0100

> On Mon, 2012-09-03 at 09:47 +0200, Giuseppe CAVALLARO wrote:
>> This patch adds the sysFs support.
>> Some internal driver parameters can be tuned by using some
>> entries exposed via sysFS. There parameter currently are,
>> for example, for internal timers used to mitigate the rx/tx
>> interrupts or for EEE.
> [...]
> 
> Why are you not exposing these through the standard ethtool operations?

Guiseppe, I'm not appyling driver patches that add sysfs crap like
this.  Either use existing ethtool interfaces or create new ones that
provide the necessary functionality.

Adding unique configuration mechanisms to a device driver is always a
bug.

And I'm getting real fed up with driver writers simply not getting the
message.  Every time someone adds sysfs or ioctl crap, we push back,
so just don't do it and stop wasting our time.
