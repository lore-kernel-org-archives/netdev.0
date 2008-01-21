From: Ben Greear <greearb@candelatech.com>
Subject: Re: questions on NAPI processing latency and dropped network packets
Date: Mon, 21 Jan 2008 13:11:13 -0800
Message-ID: <47950A71.5010304@candelatech.com>
References: <478654C3.60806@nortel.com> <4794F848.9020402@nortel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Chris Friesen <cfriesen@nortel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns2.lanforge.com ([66.165.47.211]:43594 "EHLO ns2.lanforge.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751640AbYAUVLX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 21 Jan 2008 16:11:23 -0500
In-Reply-To: <4794F848.9020402@nortel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Chris Friesen wrote:

> Is there anything else we can do to minimize the latency of network 
> packet processing and avoid having to crank the rx ring size up so high?

Why is it such a big deal to crank up the rx queue length?  Seems like
a perfectly normal way to handle bursts like this...

Thanks,
Ben


-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

