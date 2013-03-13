From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] sctp: don't break the loop while meeting the
 active_path so as to find the matched transport
Date: Wed, 13 Mar 2013 10:11:00 -0400 (EDT)
Message-ID: <20130313.101100.2171722464896294416.davem@davemloft.net>
References: <1362728377-11025-1-git-send-email-xufeng.zhang@windriver.com>
	<514084B0.4050906@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: xufeng.zhang@windriver.com, nhorman@tuxdriver.com,
	linux-sctp@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: vyasevich@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43929 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755526Ab3CMOKt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Mar 2013 10:10:49 -0400
In-Reply-To: <514084B0.4050906@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vlad Yasevich <vyasevich@gmail.com>
Date: Wed, 13 Mar 2013 09:52:48 -0400

> On 03/08/2013 02:39 AM, Xufeng Zhang wrote:
>> sctp_assoc_lookup_tsn() function searchs which transport a certain TSN
>> was sent on, if not found in the active_path transport, then go search
>> all the other transports in the peer's transport_addr_list, however,
>> we
>> should continue to the next entry rather than break the loop when meet
>> the active_path transport.
>>
>> Signed-off-by: Xufeng Zhang <xufeng.zhang@windriver.com>
 ...
> Acked-by: Neil Horman <nhorman@tuxdriver.com>
...
> Acked-by: Vlad Yasevich <vyasevich@gmail.com>

Applied, thanks everyone.
