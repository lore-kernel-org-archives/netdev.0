From: David Miller <davem@davemloft.net>
Subject: Re: [IFB]: Fix crash on input device removal
Date: Thu, 29 Mar 2007 11:49:52 -0700 (PDT)
Message-ID: <20070329.114952.85409594.davem@davemloft.net>
References: <460BE9B8.8030901@trash.net>
	<1175187135.4881.34.camel@localhost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, netdev@vger.kernel.org
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60394
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S933084AbXC2St4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Mar 2007 14:49:56 -0400
In-Reply-To: <1175187135.4881.34.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: jamal <hadi@cyberus.ca>
Date: Thu, 29 Mar 2007 12:52:15 -0400

> On Thu, 2007-29-03 at 18:30 +0200, Patrick McHardy wrote:
> > Fix the crash reported in the "another critical bug ?" thread,
> > which turned out to be caused by a stale input_dev pointer.
> > The patch applies to current -git and latest -stable.
> > 
> 
> Mucho Gracias Patrick. Dont know if the ack is needed, but here it is.
> 
> Acked-by: Jamal Hadi Salim <hadi@cyberus.ca>

It's clear that going to an ifindex for input_dev was inevitably,
thanks for taking care of this Patrick!

Patch applied, and I'll push to -stable too.
