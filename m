From: Claudio Lanconelli <lanconelli.claudio@eptar.com>
Subject: Re: [patch 2.6.24-git] net/enc28j60: oops fix, low power mode
Date: Thu, 07 Feb 2008 11:53:30 +0100
Message-ID: <47AAE32A.7070105@eptar.com>
References: <20080205190124.E72F48E45F@adsl-69-226-248-13.dsl.pltn13.pacbell.net> <47A9EA42.3080800@eptar.com> <200802062156.41862.david-b@pacbell.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Brownell <david-b@pacbell.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fe-relay03.albacom.net ([217.220.57.137]:33763 "EHLO
	fe-relay03.albacom.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754535AbYBGKwg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Feb 2008 05:52:36 -0500
In-Reply-To: <200802062156.41862.david-b@pacbell.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Brownell wrote:
> How long did that take?  I did about four dozen
>
> 	ifconfig eth1 up
> 	sleep 3
> 	ifconfig eth1 down
>
> cycles ... it worked fine.  The "sleep" was to let the link
> negotiation complete.
>
>   
After a couple of :

ifconfig eth0 down
(wait just 1 second)
ifconfig eth0 up

the network is frozen.

If I do another
ifconfig eth0 down
(wait just 1 second)
ifconfig eth0 up

restarts.
It's random, no rule.

