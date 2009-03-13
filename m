From: David Miller <davem@davemloft.net>
Subject: Re: PATCH_ppp_mp_explode_redesign
Date: Fri, 13 Mar 2009 16:09:29 -0700 (PDT)
Message-ID: <20090313.160929.74391613.davem@davemloft.net>
References: <49AD1AAB.mail7XX11MN1A@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, paulus@samba.org
To: gabriele.paoloni@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46282
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751340AbZCMXJn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Mar 2009 19:09:43 -0400
In-Reply-To: <49AD1AAB.mail7XX11MN1A@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: gabriele.paoloni@intel.com
Date: Tue, 03 Mar 2009 11:55:23 +0000

> Problem Solution:
> 
> The problem has been solved by redesigning the "ppp_mp_explode" function in such 
> a way to make it split the sk_buff buffer according to the speeds of the underlying 
> PPP channels (the speeds of the serial interfaces respectively attached to the PPP 
> channels). Referring to the above example, the redesigned "ppp_mp_explode" function 
> will now divide the 1000 Bytes buffer into two fragments whose sizes are set 
> according to the speeds of the channels where they are going to be sent on (e.g . 
> 10 Byets on 10KB/sec channel and 990 Bytes on 1000KB/sec channel). 
> The reworked function grants the same performances of the original one in optimal 
> working conditions (i.e. a bundle made up of PPP links all working at the same 
> speed), while greatly improving performances on the bundles made up of channels 
> working at different speeds.

Looks good, applied.

