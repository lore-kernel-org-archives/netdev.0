From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/1] ipvlan: Initial check-in of the IPVLAN
 driver.
Date: Tue, 11 Nov 2014 18:19:00 -0500 (EST)
Message-ID: <20141111.181900.1713364166494134373.davem@davemloft.net>
References: <1415744984-25802-1-git-send-email-maheshb@google.com>
	<CAHA+R7OZxCLFYetGHONWkL7uzGur=xSc=ASBT4i5EEeS2Xzwog@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: maheshb@google.com, netdev@vger.kernel.org, edumazet@google.com,
	maze@google.com, chavey@google.com, thockin@google.com,
	brandon.philips@coreos.com, xemul@parallels.com
To: cwang@twopensource.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34996 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752475AbaKKXTC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Nov 2014 18:19:02 -0500
In-Reply-To: <CAHA+R7OZxCLFYetGHONWkL7uzGur=xSc=ASBT4i5EEeS2Xzwog@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <cwang@twopensource.com>
Date: Tue, 11 Nov 2014 15:12:27 -0800

> On Tue, Nov 11, 2014 at 2:29 PM, Mahesh Bandewar <maheshb@google.com> wrote:
>> This driver is very similar to the macvlan driver except that it
>> uses L3 on the frame to determine the logical interface while
>> functioning as packet dispatcher. It inherits L2 of the master
>> device hence the packets on wire will have the same L2 for all
>> the packets originating from all virtual devices off of the same
>> master device.
> 
> Why do we need this from the beginning?
> IOW, what problem does this solve while macvlan doesn't?

macvlan has several built-in limitations, which IP VLAN absolutely
does not have.

Eric Dumazet spoke about this at the networking track at the kernel
summit in Chicago, maybe he or another person working on this can
chime in.
