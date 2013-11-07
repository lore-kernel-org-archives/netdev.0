From: Veaceslav Falico <vfalico@redhat.com>
Subject: Re: [BUG] v3.12-rc5-139-gbdeeab6 assertion failed at
 drivers/net/bonding/bond_main.c (3398)
Date: Thu, 7 Nov 2013 15:24:18 +0100
Message-ID: <20131107142418.GL19702@redhat.com>
References: <20131019202702.GA8354@glanzmann.de>
 <20131019205222.GA18874@redhat.com>
 <20131019.184411.2017497732906948451.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: thomas@glanzmann.de, netdev@vger.kernel.org, fubar@us.ibm.com,
	andy@greyhouse.net, nikolay@redhat.com, robbat2@gentoo.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:16650 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750964Ab3KGO0j (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Nov 2013 09:26:39 -0500
Content-Disposition: inline
In-Reply-To: <20131019.184411.2017497732906948451.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Oct 19, 2013 at 06:44:11PM -0400, David Miller wrote:
>From: Veaceslav Falico <vfalico@redhat.com>
>Date: Sat, 19 Oct 2013 22:52:22 +0200
>
>> Fixed in commit b32418705107265dfca5edfe2b547643e53a732e ("bonding:
>> RCUify
>> bond_set_rx_mode()") net-next. It should get into mainline soon.
>
>If it's in net-next it's not going into mainline soon.
>
>A change that fixes a bug should go into 'net', not 'net-next'.

Hi David,

Sorry for bringing this up - completely my fault. There are further reports
of this bug in mainline. I've read the
./Documentation/networking/netdev-FAQ.txt but haven't seen a way to get a
fix that got in net-next to the (correct) net tree.

Is there any way to do it?

Sorry again for the mess :-(.

Thank you!
