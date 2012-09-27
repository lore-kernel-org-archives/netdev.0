From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH net-next] tcp: introduce tcp_tw_interval to
 specifiy the time of TIME-WAIT
Date: Thu, 27 Sep 2012 13:05:29 -0400 (EDT)
Message-ID: <20120927.130529.620560818048014548.davem@davemloft.net>
References: <1348735261-29225-1-git-send-email-amwang@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kuznet@ms2.inr.ac.ru, kaber@trash.net,
	edumazet@google.com, nhorman@tuxdriver.com
To: amwang@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55292 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751134Ab2I0RFd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Sep 2012 13:05:33 -0400
In-Reply-To: <1348735261-29225-1-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <amwang@redhat.com>
Date: Thu, 27 Sep 2012 16:41:01 +0800

>         In commercial Unix systems, this kind of parameters, such as 
>         tcp_timewait in AIX and tcp_time_wait_interval in HP-UX, have 
>         already been available. Their implementations allow users to tune 
>         how long they keep TCP connection as TIME-WAIT state on the 
>         millisecond time scale."

This statement only makes me happy that these systems are not as
widely deployed as Linux is.

Furthermore, the mere existence of a facility in another system
is never an argument for why we should have it too.  Often it's
instead a huge reason for us not to add it.

Without appropriate confirmation that an early time-wait reuse is
valid, decreasing this interval can only be dangerous.
