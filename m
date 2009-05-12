From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: ports beeing reused too fast
Date: Tue, 12 May 2009 08:11:19 -0700
Message-ID: <20090512081119.598b22c5@nehalam>
References: <200905082311.09414.opurdila@ixiacom.com>
	<20090509153135.04874f72.billfink@mindspring.com>
	<20090509154515.28251a48@nehalam>
	<200905121532.57477.opurdila@ixiacom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Bill Fink <billfink@mindspring.com>,
	Eric Dumazet <dada1@cosmosbay.com>
To: Octavian Purdila <opurdila@ixiacom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:56239 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756392AbZELPLY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 12 May 2009 11:11:24 -0400
In-Reply-To: <200905121532.57477.opurdila@ixiacom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 12 May 2009 15:32:57 +0300
Octavian Purdila <opurdila@ixiacom.com> wrote:

> 
> > > > >> Any strong reason why a firewall would drop a SYN because ports were
> > > > >> used in a previous session ?
> > > > >
> > > > > We don't know why the firewall (Cisco FWSM) is dropping the packets,
> > > > > may be a bug, limitation or miss-configuration. We are trying to
> > > > > track this down with the firewall vendor.
> > > >
> 
> Interestingly, we are seeing the same behavior with another high-end firewall 
> (Juniper SRX). 
> 
> As mentioned previously, this can not be caused by the TW state, because the 
> connections are getting closed on the server side.
> 
> Thanks,
> tavi

I raised the issue to the original author of the proposed RFC and added
the issue to the ongoing review of the draft.

There is a suggested workaround using a bitmap but it seems like it would be
expensive to implement:
       http://ietfreport.isoc.org/all-ids/draft-ananth-tsvwg-timewait-00.txt

-- 
