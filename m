From: David Miller <davem@davemloft.net>
Subject: Re: net-next kernel NULL pointer dereference at fib_rules_tclass
Date: Tue, 10 Jul 2012 02:00:31 -0700 (PDT)
Message-ID: <20120710.020031.167904887947454063.davem@davemloft.net>
References: <alpine.LRH.2.00.1207101008270.9760@ogerlitz.voltaire.com>
	<CAF1ivSbw50US9dPxs63C8_hjdBq6K6_He7_Foi5bW1MvefunHw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ogerlitz@mellanox.com, netdev@vger.kernel.org,
	shlomop@mellanox.com, amirv@mellanox.com, erezsh@mellanox.com
To: mlin@ss.pku.edu.cn
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35774 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754516Ab2GJJAd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Jul 2012 05:00:33 -0400
In-Reply-To: <CAF1ivSbw50US9dPxs63C8_hjdBq6K6_He7_Foi5bW1MvefunHw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Lin Ming <mlin@ss.pku.edu.cn>
Date: Tue, 10 Jul 2012 16:42:29 +0800

> On Tue, Jul 10, 2012 at 3:16 PM, Or Gerlitz <ogerlitz@mellanox.com> wrote:
>> Hi Dave,
>>
>> Using latest net-next (061a5c316b6526dbc729049a16243ec27937cc31) I
>> get the below crash during the boot cycle. The crash happens on a set of
>> nodes which use igb for their onboard 1g nic, as soon as the device goes
>> up. Another group, that uses a 2nd lab, where the nodes use bnx2 for 1g
>> NIC doesn't get this crash, but the kernel there is built by a different
>> .config .
> 
> Hi,
> 
> I got similar panic, but not at boot time.
> I'll look for the cause.

Don't worry about it, I am sure that I added this bug and therefore
I will fix it.
