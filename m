From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: Re: [PATCH] mlx4_en: fix transmit of packages when blue frame is
 enabled
Date: Tue, 04 Oct 2011 08:02:12 +0200
Message-ID: <1317708132.29415.213.camel@pasglop>
References: <1317388995-411-1-git-send-email-cascardo@linux.vnet.ibm.com>
	 <953B660C027164448AE903364AC447D2235D9A8C@MTLDAG02.mtl.com>
	 <20111003143721.GA3596@oc1711230544.ibm.com>
	 <953B660C027164448AE903364AC447D2235DAA9D@MTLDAG02.mtl.com>
	 <20111003205358.GB3596@oc1711230544.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Yevgeny Petrilin <yevgenyp@mellanox.co.il>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Eli Cohen <eli@mellanox.co.il>,
	"eli@dev.mellanox.co.il" <eli@dev.mellanox.co.il>,
	linuxppc-dev@lists.ozlabs.org
To: Thadeu Lima de Souza Cascardo <cascardo@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:58324 "EHLO gate.crashing.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751555Ab1JDGCi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 4 Oct 2011 02:02:38 -0400
In-Reply-To: <20111003205358.GB3596@oc1711230544.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2011-10-03 at 17:53 -0300, Thadeu Lima de Souza Cascardo wrote:

 .../...

> > Can you also send me the output of ethtool -i?
> > It seems that there is a problem with write combining on Power processors, we will check this issue.
> > 
> > Yevgeny
> 
> Hello, Yevgeny.
> 
> You will find the output of ethtool -i below.
> 
> I am copying Ben and powerpc list, in case this is an issue with Power
> processors. They can provide us some more insight into this.

May I get some background please ? :-)

I'm not aware of a specific issue with write combining but I'd need to
know more about what you are doing and the code to do it to comment on
whether it should work or not.

Cheers,
Ben.
