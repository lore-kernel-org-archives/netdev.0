From: David Miller <davem@davemloft.net>
Subject: Re: IGMP Join dropping multicast packets
Date: Wed, 18 Mar 2009 22:46:30 -0700 (PDT)
Message-ID: <20090318.224630.262428741.davem@davemloft.net>
References: <49BEA1ED.4010907@cosmosbay.com>
	<91bdcedb0903172050td2ef895he48168987ad94472@mail.gmail.com>
	<alpine.WNT.2.00.0903181016120.5116@jbrandeb-desk1.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: daveboutcher@gmail.com, dada1@cosmosbay.com,
	netdev@vger.kernel.org, e1000-devel@lists.sourceforge.net
To: jesse.brandeburg@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40424
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752373AbZCSFqo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Mar 2009 01:46:44 -0400
In-Reply-To: <alpine.WNT.2.00.0903181016120.5116@jbrandeb-desk1.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Date: Wed, 18 Mar 2009 10:24:18 -0700 (Pacific Daylight Time)

> Interesting, this code has been there for eons (and probably this 
> behavior) but that doesn't mean its not a problem.
> 
> We are in the process of figuring out if there are any hardware corner 
> cases to changing this code (particularly in e1000)
> 
> Initial thoughts are:
> 1) kcalloc an array that we then populate with the hash functions, and 
>    then program every location only once (never flush)
> 2) only program a single hash value each time a multicast is added (bad 
>    because we can't tell the difference in the list since the last time 
>    the OS gave us the list)
> 
> It really seems like this should be fixable, and I agree that the driver 
> behavior is far from optimal, however well entrenched.

Just do what tg3 does to fix this now, get fancy and "beautiful"
later.
