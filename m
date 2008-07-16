From: David Miller <davem@davemloft.net>
Subject: Re: IPV4: Enable IP_ID sequencing for all traffic (inquiring minds
 want to know why its set to zero)
Date: Wed, 16 Jul 2008 13:27:42 -0700 (PDT)
Message-ID: <20080716.132742.24082252.davem@davemloft.net>
References: <487E0C15.1070001@linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: cl@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51824
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754295AbYGPU1n (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Jul 2008 16:27:43 -0400
In-Reply-To: <487E0C15.1070001@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Christoph Lameter <cl@linux-foundation.org>
Date: Wed, 16 Jul 2008 09:56:21 -0500

> There is some security reason why we set IP_ID == 0 right? Could
> someone point me at the discussions that lead to having IP_ID be
> zero? Have not been involved in network that much so forgive my
> ignorance.... and I can only find some hints about why this was done
> here and there using google.

As David mentioned, one reason is that the less you allocate the less often
ID wrap occurs, which is a very real issue on high speed networks.

I think a more important question is what do you want it re-enabled?
You must have stumbled upon this for a reason. :-)
