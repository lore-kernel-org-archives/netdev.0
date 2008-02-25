From: Patrick McHardy <kaber@trash.net>
Subject: Re: New sparse warning in net/mac80211/debugfs_sta.c
Date: Mon, 25 Feb 2008 12:47:20 +0100
Message-ID: <47C2AAC8.8020202@trash.net>
References: <1203589042.17534.145.camel@johannes.berg>	<1203616486.7181.269.camel@localhost>	<47BDBC23.5080007@trash.net> <20080223.200202.255773165.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: joe@perches.com, johannes@sipsolutions.net,
	harvey.harrison@gmail.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:47392 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751490AbYBYLr2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Feb 2008 06:47:28 -0500
In-Reply-To: <20080223.200202.255773165.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: Patrick McHardy <kaber@trash.net>
> Date: Thu, 21 Feb 2008 19:00:03 +0100
>
>   
>> And adds back the overhead of two completely unnecessary
>> function calls to the VLAN fastpath. How about just
>> stopping this idiocy and reverting the appropriate patches
>> to bring back MAC_FMT and use it where appropriate?
>>     
>
> Agreed, I'll do that.
>   

It would be good if Joe could go through the remaining print_mac users
and convert the remaining unintended function calls in fastpaths back
to MAC_FMT. Grepping for "start_xmit" in commit 0795af5729b shows that
at least 10 hard_start_xmit functions are affected and I expect that
some of the changes in the wireless code affect fastpaths as well.


