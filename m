From: Christoph Lameter <cl@linux.com>
Subject: Re: PATCH: Multicast: Filter multicast traffic per socket mc_list
Date: Mon, 20 Apr 2009 12:43:45 -0400 (EDT)
Message-ID: <alpine.DEB.1.10.0904201242270.1585@qirst.com>
References: <OFDADDACF0.D592E966-ON8825759B.0073E304-8825759B.00763DF6@us.ibm.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	netdev-owner@vger.kernel.org, nhorman@tuxdriver.com,
	vladislav.yasevich@hp.com
To: David Stevens <dlstevens@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.ultrahosting.com ([74.213.174.254]:42901 "EHLO
	smtp.ultrahosting.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751029AbZDTQwE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Apr 2009 12:52:04 -0400
In-Reply-To: <OFDADDACF0.D592E966-ON8825759B.0073E304-8825759B.00763DF6@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 17 Apr 2009, David Stevens wrote:

>         Linux is not Solaris. I think Solaris is wrong to change the
> behavior from the original BSD behavior, but it should be no surprise
> that there are other differences in the API's, too. It's not difficult
> to write code that works as intended on both, and the case Solaris is
> trying to avoid is not really avoided since you can still receive
> unicast traffic, or totally unrelated multicast traffic on the shared
> port and multicast address space. If the app doesn't use the port to

By that you mean unrelated multicast traffic destined to the same
multicast address and port?

