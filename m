From: Jamie Gloudon <jamie.gloudon@gmail.com>
Subject: Re: BUG: TCPDUMP invalid cksum persists after disabling TCP cksum
 offload
Date: Tue, 18 Sep 2012 18:20:40 -0400
Message-ID: <20120918222040.GA19201@darkstar>
References: <20120918193208.GA19030@darkstar>
 <1347998905.2685.29.camel@bwh-desktop.uk.solarflarecom.com>
 <20120918211423.GA19115@darkstar>
 <CAGK4HS9LSAGJ4amNK-rWKFNz=ZCVLkQm4sWABhY5C+6DBWsmUA@mail.gmail.com>
 <5058ED9E.1000902@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Vijay Subramanian <subramanian.vijay@gmail.com>,
	netdev@vger.kernel.org
To: Rick Jones <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f46.google.com ([209.85.216.46]:41170 "EHLO
	mail-qa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755351Ab2IRWUs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Sep 2012 18:20:48 -0400
Received: by qaas11 with SMTP id s11so2942670qaa.19
        for <netdev@vger.kernel.org>; Tue, 18 Sep 2012 15:20:47 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <5058ED9E.1000902@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Rick is correct. Disabling TX CKO also disable TSO. You can see that in
my ethtool output.

On Tue, Sep 18, 2012 at 02:54:38PM -0700, Rick Jones wrote:
> On 09/18/2012 02:46 PM, Vijay Subramanian wrote:
> >>The results after disabling tcp cksum offload feature:
> >># ethtool -K eth1 tx off
> >
> >Instead of this, can you try
> ># ethtool -K eth1 tso off
> 
> Doesn't TSO depend on TX CKO being enabled?  That is, if TX CKO were
> disabled, shouldn't TSO have been implicitly disabled at the same time?
> 
> rick jones
