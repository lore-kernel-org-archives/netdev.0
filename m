From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv6 addrconf: Fix addrconf_ifid_eui64 of 802.15.4
 devices
Date: Thu, 07 Mar 2013 18:17:51 -0500 (EST)
Message-ID: <20130307.181751.2267151221127000913.davem@davemloft.net>
References: <1362687183-3425-1-git-send-email-alex.aring@gmail.com>
	<1362696088.2936.47.camel@bwh-desktop.uk.solarflarecom.com>
	<1362697025.15793.221.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bhutchings@solarflare.com, alex.aring@gmail.com,
	kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	linux-zigbee-devel@lists.sourceforge.net, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47295 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755554Ab3CGXRx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Mar 2013 18:17:53 -0500
In-Reply-To: <1362697025.15793.221.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 07 Mar 2013 14:57:05 -0800

> On Thu, 2013-03-07 at 22:41 +0000, Ben Hutchings wrote:
>> On Thu, 2013-03-07 at 21:13 +0100, Alexander Aring wrote:
>> > The function addrconf_ifid_eui64 will copy eui into dev->dev_addr.
>> > We need first to manipulate eui[0] before we call memcpy afterwards.
>> 
>> memcpy() does not work that way.
>> 
>> > Broken since commit:
>> > 5e98a36ed4bf6ea396170e3af0dd4fcbe51d772f
>> > 
>> > Since this commit I got many trouble with the ieee802154 stack.
>> 
>> Your change is effectively reverting that commit.
> 
> Reverting the commit seems the solution ;)

So Yoshifuji HIDEAKI and Alexander need to work out what is happening
here.
