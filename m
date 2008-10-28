From: "Chris Friesen" <cfriesen@nortel.com>
Subject: Re: [BUG] oops in net_rx_action on 64-bit powerpc
Date: Tue, 28 Oct 2008 16:59:53 -0600
Message-ID: <49079969.3090100@nortel.com>
References: <4902B1D8.8070800@nortel.com>	<20081025.001703.261277154.davem@davemloft.net>	<49065942.4040300@nortel.com> <20081028.155128.144329082.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linuxppc-dev@ozlabs.org, romieu@fr.zoreil.com,
	jesse.brandeburg@intel.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zrtps0kn.nortel.com ([47.140.192.55]:59935 "EHLO
	zrtps0kn.nortel.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753138AbYJ1XAh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Oct 2008 19:00:37 -0400
In-Reply-To: <20081028.155128.144329082.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: "Chris Friesen" <cfriesen@nortel.com>
> Date: Mon, 27 Oct 2008 18:13:54 -0600
> 
> 
>>[PATCH] fix amd8111e rx return code
>>
>>The amd8111e rx poll routine currently mishandles the case when we process
>>exactly the number of packets specified in the budget.
>>
>>This patch is basically as suggested by David Miller.
>>
>>Signed-off-by: Chris Friesen <cfriesen@nortel.com>
> 
> 
> I had to apply this by hand because your email client heavily
> corrupted the patch.

Crap.  Sorry about that, it looks like I forgot to set my line-wrap to 0 
before creating the email.  @#$#% Thunderbird.

Chris
