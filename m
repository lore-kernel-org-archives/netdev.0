From: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Subject: RE: [PATCH] NET: Multiqueue network device support.
Date: Wed, 6 Jun 2007 15:57:35 -0700
Message-ID: <D5C1322C3E673F459512FB59E0DDC32902FC6243@orsmsx414.amr.corp.intel.com>
References: <20070606.153530.48530367.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <kaber@trash.net>, <netdev@vger.kernel.org>, <jeff@garzik.org>,
	"Kok, Auke-jan H" <auke-jan.h.kok@intel.com>, <hadi@cyberus.ca>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:33518 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965495AbXFFW5h convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Jun 2007 18:57:37 -0400
Content-class: urn:content-classes:message
In-Reply-To: <20070606.153530.48530367.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> However, I have to disagree with your analysis of the 
> multi-qdisc situation, and I tend to agree with Patrick.
> 
> If you only have one qdisc to indicate status on, when is the 
> queue full?  That is the core issue.  Indicating full status 
> when any of the hardware queues are full is broken, because 
> we should never block out queuing of higher priority packets 
> just because the low priority queue can't take any more 
> frames, _and_ vice versa.
> 
> I really want to believe your proofs but they are something 
> out of a fairy tale :-)

Dave,
	Can we move forward on this please?  If you are comfortable that
my patches give the kernel the ability to manage hardware queues
sufficiently, I'd like to request that 2.6.23 be opened (wink wink) so I
can submit the patches for inclusion to that kernel.

Thanks,

-PJ Waskiewicz
peter.p.waskiewicz.jr@intel.com
