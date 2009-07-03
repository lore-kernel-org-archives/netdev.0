From: David Miller <davem@davemloft.net>
Subject: Re: [RFC] arp announce, arp_proxy and windows ip conflict
 verification
Date: Fri, 03 Jul 2009 13:20:05 -0700 (PDT)
Message-ID: <20090703.132005.113285172.davem@davemloft.net>
References: <200907030246.18054.denys@visp.net.lb>
	<m1ab3mihjv.fsf@fess.ebiederm.org>
	<200907031402.34941.denys@visp.net.lb>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ebiederm@xmission.com, netdev@vger.kernel.org
To: denys@visp.net.lb
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49419
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757978AbZGCUT7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Jul 2009 16:19:59 -0400
In-Reply-To: <200907031402.34941.denys@visp.net.lb>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Denys Fedoryschenko <denys@visp.net.lb>
Date: Fri, 3 Jul 2009 14:02:34 +0300

> Anyway, i ask advice from one of RFC authors. I will forward it here
> as soon as receive it.

Regardless of what this person says, I must bring up the most
important issue.

If we change this behvaior we have now, which has been present for
more than 10 years, we will break someone's setup potentially and that
must be considered strongly against all the other arguments.

I really never should have applied your initial patch, I severely
regret it.  Thanksfully it's reverted now and we can look into
this issue more properly.

