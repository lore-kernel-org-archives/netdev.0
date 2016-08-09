From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bonding: Allow tun-interfaces as slaves
Date: Tue, 09 Aug 2016 12:06:36 -0700 (PDT)
Message-ID: <20160809.120636.2039586307820412288.davem@davemloft.net>
References: <CAD=hENd01nGdvB9GseG+CrWn3f0PXyGgwOmf=+MVAfuW7Hv9Nw@mail.gmail.com>
	<57A9DA8D.3010407@huawei.com>
	<20160809180830.GM22974@cork>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: 8BIT
Cc: dingtianhong@huawei.com, zyjzyj2000@gmail.com, fubar@us.ibm.com,
	andy@greyhouse.net, netdev@vger.kernel.org
To: joern@purestorage.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:36361 "EHLO
	mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751774AbcHITGi convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Aug 2016 15:06:38 -0400
Received: by mail-pf0-f195.google.com with SMTP id y134so1320743pfg.3
        for <netdev@vger.kernel.org>; Tue, 09 Aug 2016 12:06:38 -0700 (PDT)
In-Reply-To: <20160809180830.GM22974@cork>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jörn Engel <joern@purestorage.com>
Date: Tue, 9 Aug 2016 11:08:30 -0700

> On Tue, Aug 09, 2016 at 09:28:45PM +0800, Ding Tianhong wrote:
>> 
>> I think if the bonding dev has to support L3 virtual device, we need to add new bond features to distinguish the dev and make the
>> bond xmit and transfer without the mac address.
> 
> Simply not checking errors when setting the mac address solves the
> problem for me.  No new features needed.

But it only works in certain modes.

So the best we can do is enforce the MAC address setting in the
modes that absolutely require it.  We cannot ignore the MAC
address setting unilaterally.
