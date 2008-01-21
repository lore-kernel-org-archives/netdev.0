From: "Chris Friesen" <cfriesen@nortel.com>
Subject: Re: questions on NAPI processing latency and dropped network packets
Date: Mon, 21 Jan 2008 13:53:44 -0600
Message-ID: <4794F848.9020402@nortel.com>
References: <478654C3.60806@nortel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from zrtps0kp.nortel.com ([47.140.192.56]:44629 "EHLO
	zrtps0kp.nortel.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752475AbYAUTxy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jan 2008 14:53:54 -0500
In-Reply-To: <478654C3.60806@nortel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I've done some further digging, and it appears that one of the problems 
we may be facing is very high instantaneous traffic rates.

Instrumentation showed up to 222K packets/sec for short periods (at 
least 1.1 ms, possibly longer), although the long-term average is down 
around 14-16K packets/sec.

If I bump the rx ring size up to 4096, we can handle all the packets and 
we still have 44% idle on cpu0 and 27% idle on cpu1.

Is there anything else we can do to minimize the latency of network 
packet processing and avoid having to crank the rx ring size up so high?

Thanks,

Chris
