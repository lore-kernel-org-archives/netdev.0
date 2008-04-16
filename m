From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6.26 2/2] Do not allocate unneeded memory for
 dev->priv alignment.
Date: Wed, 16 Apr 2008 02:17:06 -0700 (PDT)
Message-ID: <20080416.021706.250552589.davem@davemloft.net>
References: <47FA5D62.5040806@gmail.com>
	<47FB2FF3.90104@openvz.org>
	<20080408092253.GA4048@ff.dom.local>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: xemul@openvz.org, netdev@vger.kernel.org, shemminger@vyatta.com,
	kaber@trash.net
To: jarkao2@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50828
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754460AbYDPJRF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Apr 2008 05:17:05 -0400
In-Reply-To: <20080408092253.GA4048@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jarek Poplawski <jarkao2@gmail.com>
Date: Tue, 8 Apr 2008 09:22:53 +0000

> On Tue, Apr 08, 2008 at 12:42:27PM +0400, Pavel Emelyanov wrote:
> > Hmm, AFAIC, the net_device alignment is done earlier, while this one
> > makes sense in case the priv pointer alignment.
> 
> Hmm, one NETDEV_ALIGN_CONST is later used just for net_device alignment,
> and you could not fit this struct after "~NETDEV_ALIGN_CONST" without
> adding anything. So you should probably skip "~NETDEV_ALIGN_CONST" in
> this no priv case too?

The Linux NETDEV Patch Robot has determined that these other
NETDEV_ALIGN_CONST instances need to be retained, therefore
Pavel's patch will be applied to net-2.6.26.

*beep* *beep*

Thank you for your valuable feedback.

*beep* *beep*

Keep hacking.
