From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/2] net: bcmgenet: Byte Queue Limits support
Date: Fri, 13 Mar 2015 19:13:09 -0400 (EDT)
Message-ID: <20150313.191309.328275504066280003.davem@davemloft.net>
References: <1426287512-10742-1-git-send-email-f.fainelli@gmail.com>
	<55036CCF.5020200@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, edumazet@google.com, jaedon.shin@gmail.com,
	pgynther@google.com
To: f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55167 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751308AbbCMXNN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Mar 2015 19:13:13 -0400
In-Reply-To: <55036CCF.5020200@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <f.fainelli@gmail.com>
Date: Fri, 13 Mar 2015 16:03:43 -0700

> On 13/03/15 15:58, Florian Fainelli wrote:
>> Hi all,
>> 
>> This path series adds byte queue limits support to the GENET driver. Just like
>> the gianfar driver, we sometimes need to insert a 64 bytes transmit status block
>> which is not going to be sent on the wire, just to the TDMA/TBUF, so we need to
>> record the correct byte count before doing that SKB inflation.
> 
> David, please hold this patch series for now, I found a bunch of small
> corner cases with it while bring up/down the interface, will respin later.

Ok.
