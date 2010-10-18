From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: Bug#595265: linux-image-2.6.32-5-686: Nerwork card fails to come
 up again after suspend
Date: Mon, 18 Oct 2010 23:45:36 +0200
Message-ID: <20101018214536.GA14344@electric-eye.fr.zoreil.com>
References: <20100902154312.12515.10390.reportbug@bird.umass.edu>
 <201009211624.12744.aboelens@engin.umass.edu>
 <1286760421.2955.287.camel@localhost>
 <201010171116.00514.aboelens@engin.umass.edu>
 <1287361431.20865.133.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Arnout Boelens <aboelens@engin.umass.edu>, 595265@bugs.debian.org,
	netdev <netdev@vger.kernel.org>
To: Ben Hutchings <ben@decadent.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 88-139-115-126.adslgp.cegetel.net ([88.139.115.126]:51239 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1755181Ab0JRVqg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Oct 2010 17:46:36 -0400
Content-Disposition: inline
In-Reply-To: <1287361431.20865.133.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ben Hutchings <ben@decadent.org.uk> :
[...]
> Arnout Boelens reported that his RTL8111/8168B fails to link-up after
> suspend and resume, both under Debian's kernel based on 2.6.32 and under
> 2.6.36-rc6.  Full details are at <http://bugs.debian.org/595265>, though
> the log isn't very informative:
> 
> [31837.396594] PM: Finishing wakeup.
> [31837.396597] Restarting tasks ... done.
> [31840.267267] r8169: eth0: link down
> 
> Can you suggest how to investigate this further?

Something like the patch made by Stanislaw at :
https://bugzilla.redhat.com/show_bug.cgi?id=502974

-- 
Ueimor
