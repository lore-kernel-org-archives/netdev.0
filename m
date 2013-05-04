From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] gre: Fix GREv4 TCPv6 segmentation.
Date: Fri, 03 May 2013 23:18:20 -0400 (EDT)
Message-ID: <20130503.231820.1791825277635976221.davem@davemloft.net>
References: <1367547259-17919-1-git-send-email-pshelar@nicira.com>
	<20130503.161149.1251743328601859737.davem@davemloft.net>
	<CALnjE+qniQGq8azFE0AwmY545zgD+71fLtGmxzrytN_fVhMa1A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, sesse@google.com, eric.dumazet@gmail.com
To: pshelar@nicira.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51795 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750806Ab3EDDSW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 May 2013 23:18:22 -0400
In-Reply-To: <CALnjE+qniQGq8azFE0AwmY545zgD+71fLtGmxzrytN_fVhMa1A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pravin Shelar <pshelar@nicira.com>
Date: Fri, 3 May 2013 15:54:11 -0700

> On Fri, May 3, 2013 at 1:11 PM, David Miller <davem@davemloft.net> wrote:
>> From: Pravin B Shelar <pshelar@nicira.com>
>> Date: Thu,  2 May 2013 19:14:19 -0700
>>
>>> For ipv6 traffic, GRE can generate packet with strange GSO
>>> bits, e.g. ipv4 packet with SKB_GSO_TCPV6 flag set.  Therefore
>>> following patch relaxes check in inet gso handler to allow
>>> such packet for segmentation.
>>> This patch also fixes wrong skb->protocol set that was done in
>>> gre_gso_segment() handler.
>>>
>>> Reported-by: Steinar H. Gunderson <sesse@google.com>
>>> CC: Eric Dumazet <eric.dumazet@gmail.com>
>>> Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
>>
>> Applied.
> 
> Hi David,
> 
> This patch needs to be queued for -stable.

Added, thanks.
