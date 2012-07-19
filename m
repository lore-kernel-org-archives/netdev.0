From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 3/7] net-tcp: Fast Open client - sending SYN-data
Date: Thu, 19 Jul 2012 10:59:46 -0700 (PDT)
Message-ID: <20120719.105946.587126825843724015.davem@davemloft.net>
References: <1342716191-19196-1-git-send-email-ycheng@google.com>
	<1342716191-19196-4-git-send-email-ycheng@google.com>
	<1342720671.2626.4650.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ycheng@google.com, hkchu@google.com, edumazet@google.com,
	ncardwell@google.com, sivasankar@cs.ucsd.edu,
	netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46941 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751380Ab2GSR7r (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Jul 2012 13:59:47 -0400
In-Reply-To: <1342720671.2626.4650.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 19 Jul 2012 19:57:51 +0200

> On Thu, 2012-07-19 at 09:43 -0700, Yuchung Cheng wrote:
>> This patch implements sending SYN-data in tcp_connect(). The data is
>> from tcp_sendmsg() with flag MSG_FASTOPEN (implemented in a later patch).
>> 
>> The length of the cookie in tcp_fastopen_req, init'd to 0, controls the
>> type of the SYN. If the cookie is not cached (len==0), the host sends
>> data-less SYN with Fast Open cookie request option to solicit a cookie
>> from the remote. If cookie is not available (len > 0), the host sends
>> a SYN-data with Fast Open cookie option. If cookie length is negative,
>>   the SYN will not include any Fast Open option (for fall back operations).
>> 
>> To deal with middleboxes that may drop SYN with data or experimental TCP
>> option, the SYN-data is only sent once. SYN retransmits do not include
>> data or Fast Open options. The connection will fall back to regular TCP
>> handshake.
>> 
>> Signed-off-by: Yuchung Cheng <ycheng@google.com>
 ...
> Eric Dumazet <edumazet@google.com>

I guess you're trying to ACK this? :-)
