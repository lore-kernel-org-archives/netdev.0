From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH]: tipc: Fix oops on send prior to entering networked
 mode
Date: Thu, 25 Feb 2010 07:13:53 -0800 (PST)
Message-ID: <20100225.071353.10926250.davem@davemloft.net>
References: <20100224211507.GC15380@hmsreliant.think-freely.org>
	<20100224.173811.264809559.davem@davemloft.net>
	<29C1DC0826876849BDD9F1C67ABA2943070F1849@ala-mail09.corp.ad.wrs.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nhorman@tuxdriver.com, netdev@vger.kernel.org,
	jon.maloy@ericsson.com, tipc-discussion@lists.sourceforge.net,
	hady@cyberus.ca
To: allan.stephens@windriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42271
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932335Ab0BYPNf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Feb 2010 10:13:35 -0500
In-Reply-To: <29C1DC0826876849BDD9F1C67ABA2943070F1849@ala-mail09.corp.ad.wrs.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Stephens, Allan" <allan.stephens@windriver.com>
Date: Thu, 25 Feb 2010 06:24:15 -0800

> Later, the company that employs me found it necessary to enhance TIPC
> with new capabilities which would be included in a couple of our
> operating systems (one of which is Linux-based).  To meet our schedule,
> it was necessary to make a large number of major changes to TIPC, and it
> was felt that submitting these relatively untested changes to mainstream
> Linux would be potentially destabilzing and therefore undesirable.

Things were going just fine until Ericsson farmed the TIPC stuff out
to you guys, really.

In fact, an incredible amount of effort was made by the Ericsson folks
to get the TIPC stack upstream in the first place.

And now you guys made all of that basically for naught by taking your
work downstream.

A healthy upstream project turned into a "business decision."

Thanks!

The fact is, you would have had LESS work to do if you have integrated
your work upstream as a rule.  Us upstream folks would have been
handling any and all networking API changes transparently for you.

And people who run automated tools to validate code and look for bugs
would have been fixing bugs in TIPC for you.

The list goes on an on.

But it doesn't make any "business sense" for you to work on your code
upstream so you didn't do it.

And now you want to suggest that we dump huge unreviewable chunks of
code into the tree, again because it's less work for _YOU_.

Thanks!
