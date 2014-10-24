From: "Tantilov, Emil S" <emil.s.tantilov@intel.com>
Subject: RE: ixgbe driver fails occasionally since
 ee98b577e7711d5890ded2c7b05578a29512bd39
Date: Fri, 24 Oct 2014 21:33:41 +0000
Message-ID: <87618083B2453E4A8714035B62D6799250169599@FMSMSX105.amr.corp.intel.com>
References: <20141023140625.GD1480@cisco.com>
 <87618083B2453E4A8714035B62D679925016872B@FMSMSX105.amr.corp.intel.com>
 <20141024091828.GA1488@cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Scott Harrison <scoharr2@cisco.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:30583 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751573AbaJXVdy convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Oct 2014 17:33:54 -0400
In-Reply-To: <20141024091828.GA1488@cisco.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>-----Original Message-----
>From: Scott Harrison [mailto:scoharr2@cisco.com]
>Sent: Friday, October 24, 2014 2:18 AM
>To: Tantilov, Emil S
>Cc: netdev@vger.kernel.org
>Subject: Re: ixgbe driver fails occasionally since ee98b577e7711d5890ded2c7b05578a29512bd39
>
>Emil,
>
>Sorry, I should have looked harder it happens as part of ifup eth0, we have
>"/sbin/ethtool -s eth0 autoneg on" in the interfaces file.

Well you can avoid this issue by removing this command since it is not needed for anything.
The interface will auto-negotiate by default.

We were able to reproduce this issue and will work on a fix.

Thanks a lot for reporting it.

Emil

>
>HTH.
>
>Scott.
