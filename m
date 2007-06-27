From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] NET: Multiqueue network device support.
Date: Wed, 27 Jun 2007 15:54:57 -0700 (PDT)
Message-ID: <20070627.155457.35508432.davem@davemloft.net>
References: <1182864448.5186.34.camel@localhost>
	<20070626.135756.30187055.davem@davemloft.net>
	<1182983565.5155.12.camel@localhost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yi.zhu@intel.com, kaber@trash.net, peter.p.waskiewicz.jr@intel.com,
	netdev@vger.kernel.org, jeff@garzik.org, auke-jan.h.kok@intel.com
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60856
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1758643AbXF0Wyi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Jun 2007 18:54:38 -0400
In-Reply-To: <1182983565.5155.12.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: jamal <hadi@cyberus.ca>
Date: Wed, 27 Jun 2007 18:32:45 -0400

> On Tue, 2007-26-06 at 13:57 -0700, David Miller wrote:
> > From: jamal <hadi@cyberus.ca>
> > Date: Tue, 26 Jun 2007 09:27:28 -0400
> > 
> > > Back to the question: Do you recall how this number was arrived at? 
> > > 128 packets will be sent out at GiGe in about 80 microsecs, so from a
> > > feel-the-wind-direction perspective it seems reasonable.
> > 
> > I picked it out of a hat.
> 
> It is not a bad value for Gige; doubt it will be a good one for 10/100
> or even 10GE.
> But you could say that about the ring sizes too.

The thing that's really important is that the value is not so
large such that the TX ring can become empty.
