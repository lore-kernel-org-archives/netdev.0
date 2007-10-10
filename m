From: Patrick McHardy <kaber@trash.net>
Subject: Re: [re] Possible 2.6.22 -> 2.6.23 HTB regression?
Date: Wed, 10 Oct 2007 14:45:51 +0200
Message-ID: <470CC97F.4000906@trash.net>
References: <20071010124510.M18768@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Denys <denys@visp.net.lb>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:60515 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752559AbXJJMtI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Oct 2007 08:49:08 -0400
In-Reply-To: <20071010124510.M18768@visp.net.lb>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Denys wrote:
>>What does /proc/net/psched contain?
> 
> visp-1 ~ # cat /proc/net/psched
> 000003e8 00000400 000f4240 3b9aca00


OK, hrtimers are disabled on your system, but we still announce
the usec clock resolution to userspace, which is used by HTB to
calculate the burst rate. But actually that can't be the reason
since that has already been the case in 2.6.22. Please post a diff
of the bootlog from 2.6.22 and 2.6.23.

