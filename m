From: Octavian Purdila <opurdila@ixiacom.com>
Subject: Re: [rfc] new sk_buff member: hwstamp
Date: Tue, 15 Jul 2008 13:39:14 +0300
Message-ID: <200807151339.14868.opurdila@ixiacom.com>
References: <200807141843.00845.opurdila@ixiacom.com> <20080714174321.30d6d62a@extreme>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ixia01.ro.gtsce.net ([212.146.94.66]:4382 "EHLO
	ixro-ex1.ixiacom.com" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754866AbYGOKlV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Jul 2008 06:41:21 -0400
In-Reply-To: <20080714174321.30d6d62a@extreme>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tuesday 15 July 2008, Stephen Hemminger wrote:

>
> Why not do some clock synchronization and use existing absolute timestamp?
> This would benefit system generally since it would give more accurate
> values for network traffic analysis.
>

Sorry if I repeat myself, but I get the feeling that I did a poor job 
explaining the issue, so here is another try :)

Yes, we could try to do some real-time clock synchronization, but I don't 
think that we will be able to achieve the same level of synchronization 
accuracy that we can have at the NIC level (where our timestamping units are 
hardware synchronized within 20ns).

Thanks,
tavi
