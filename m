From: David Miller <davem@davemloft.net>
Subject: Re: oops during unregister_netdevice interface enslaved to bond -
 regression
Date: Tue, 10 May 2011 12:25:27 -0700 (PDT)
Message-ID: <20110510.122527.39197304.davem@davemloft.net>
References: <OF0F4919C3.B9CFCAE8-ONC125788C.002D5EB1-C125788C.002D83B7@de.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Frank.Blaschka@de.ibm.com
To: ELELUECK@de.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53077
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750704Ab1EJTZ7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 May 2011 15:25:59 -0400
In-Reply-To: <OF0F4919C3.B9CFCAE8-ONC125788C.002D5EB1-C125788C.002D83B7@de.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Einar EL Lueck <ELELUECK@de.ibm.com>
Date: Tue, 10 May 2011 10:17:09 +0200

> Calls to the *_many functions introduced by Octavian may never interleave
> because
> the traversed lists modify each other. This was the root cause for the
> symptom that Frank discovered. Octavian is not a valid mail recipient
> anymore and did not react from any new mail address. I suggest to revert
> the commit.

I don't think a pure-revert is appropriate in this case, the regression
that will introduce is almost as serious as the OOPS here.

Someone just needs to work on a fix.
