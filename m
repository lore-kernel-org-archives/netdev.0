From: Patrick McHardy <kaber@trash.net>
Subject: Re: New sparse warning in net/mac80211/debugfs_sta.c
Date: Thu, 21 Feb 2008 19:15:53 +0100
Message-ID: <47BDBFD9.1080808@trash.net>
References: <1203586467.20345.14.camel@brick>	 <20080221.015743.222059206.davem@davemloft.net>	 <1203588079.20345.15.camel@brick>	 <20080221.020554.259219477.davem@davemloft.net>	 (sfid-20080221_100524_615638_119EBE24)  <1203589042.17534.145.camel@johannes.berg> <1203616486.7181.269.camel@localhost> <47BDBC23.5080007@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Johannes Berg <johannes@sipsolutions.net>,
	David Miller <davem@davemloft.net>, harvey.harrison@gmail.com,
	netdev@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:57524 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753226AbYBUSQN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Feb 2008 13:16:13 -0500
In-Reply-To: <47BDBC23.5080007@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Patrick McHardy wrote:
> Joe Perches wrote:
>>
>> This removes the __pure from print_mac, so reject as appropriate...
>>
>> Add some type safety to print_mac by using struct print_mac_buf * 
>> instead of char *.
>
> And adds back the overhead of two completely unnecessary
> function calls to the VLAN fastpath. 

BTW, this also affects ATM, with 3 calls in hard_start_xmit,
3 calls in lec_xmit and 1 cakk in lec_atm_send.

> How about just
> stopping this idiocy and reverting the appropriate patches
> to bring back MAC_FMT and use it where appropriate? 

