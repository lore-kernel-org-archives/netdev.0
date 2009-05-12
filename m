From: Octavian Purdila <opurdila@ixiacom.com>
Subject: Re: ports beeing reused too fast
Date: Tue, 12 May 2009 18:52:25 +0300
Message-ID: <200905121852.26099.opurdila@ixiacom.com>
References: <200905082311.09414.opurdila@ixiacom.com> <200905121532.57477.opurdila@ixiacom.com> <20090512081119.598b22c5@nehalam>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Bill Fink <billfink@mindspring.com>,
	Eric Dumazet <dada1@cosmosbay.com>,
	Cosmin Ratiu <cratiu@ixiacom.com>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ixro-out-rtc.ixiacom.com ([92.87.192.98]:13483 "EHLO
	ixro-ex1.ixiacom.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754740AbZELPxg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 May 2009 11:53:36 -0400
In-Reply-To: <20090512081119.598b22c5@nehalam>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> I raised the issue to the original author of the proposed RFC and added
> the issue to the ongoing review of the draft.
>
> There is a suggested workaround using a bitmap but it seems like it would
> be expensive to implement:
>       
> http://ietfreport.isoc.org/all-ids/draft-ananth-tsvwg-timewait-00.txt

OK, I now understand how TW could be an issue here - I didn't realize that we 
could have sockets in TW on the server side.

Since the workaround seems expensive, would it be acceptable to add a new 
sysctl option to disable port randomization?

Thanks,
tavi

