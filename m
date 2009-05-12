From: Octavian Purdila <opurdila@ixiacom.com>
Subject: Re: ports beeing reused too fast
Date: Tue, 12 May 2009 15:32:57 +0300
Message-ID: <200905121532.57477.opurdila@ixiacom.com>
References: <200905082311.09414.opurdila@ixiacom.com> <20090509153135.04874f72.billfink@mindspring.com> <20090509154515.28251a48@nehalam>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	Bill Fink <billfink@mindspring.com>,
	Eric Dumazet <dada1@cosmosbay.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ixro-out-rtc.ixiacom.com ([92.87.192.98]:16805 "EHLO
	ixro-ex1.ixiacom.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1756085AbZELMeJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 May 2009 08:34:09 -0400
In-Reply-To: <20090509154515.28251a48@nehalam>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> > > >> Any strong reason why a firewall would drop a SYN because ports were
> > > >> used in a previous session ?
> > > >
> > > > We don't know why the firewall (Cisco FWSM) is dropping the packets,
> > > > may be a bug, limitation or miss-configuration. We are trying to
> > > > track this down with the firewall vendor.
> > >

Interestingly, we are seeing the same behavior with another high-end firewall 
(Juniper SRX). 

As mentioned previously, this can not be caused by the TW state, because the 
connections are getting closed on the server side.

Thanks,
tavi

