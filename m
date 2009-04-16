From: David Miller <davem@davemloft.net>
Subject: Re: PATCH: Multicast: Filter multicast traffic per socket mc_list
Date: Thu, 16 Apr 2009 15:15:37 -0700 (PDT)
Message-ID: <20090416.151537.184847548.davem@davemloft.net>
References: <OF8AB07938.3DA9C6DD-ON8825759A.00522BB7-8825759A.0053414D@us.ibm.com>
	<alpine.DEB.1.10.0904161133320.15629@qirst.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dlstevens@us.ibm.com, netdev@vger.kernel.org,
	netdev-owner@vger.kernel.org, nhorman@tuxdriver.com,
	vladislav.yasevich@hp.com
To: cl@linux.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41181
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751228AbZDPWPq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Apr 2009 18:15:46 -0400
In-Reply-To: <alpine.DEB.1.10.0904161133320.15629@qirst.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Christoph Lameter <cl@linux.com>
Date: Thu, 16 Apr 2009 11:36:10 -0400 (EDT)

> On Thu, 16 Apr 2009, David Stevens wrote:
> 
>> This isn't what I suggested-- you have the default backwards. It must
>> default
>> to current behavior, or it's pointless.
> 
> If it would default to the current behavior then it would be incompatible
> with the behavior of other operating systems and the surprising behavior
> of the Linux multicast stack would continue to exist. The unusual behavior
> needs to be switched on if wanted for legacy or other reasons.

Umm, no.

We don't break existing applications "by default".

You're being entirely selfish here, you want your application to work
without having to specify the socket option to get the new behavior.

Well guess what?  Under Linux you will have to!
