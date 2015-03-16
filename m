From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next V2 0/3] Add max rate TXQ attribute
Date: Mon, 16 Mar 2015 15:50:20 -0400 (EDT)
Message-ID: <20150316.155020.1838817631290149166.davem@davemloft.net>
References: <1426424596-3911-1-git-send-email-ogerlitz@mellanox.com>
	<CALx6S37qzKSJ8cWiCDmfHM=bRy67jup4YriMkL6tw9BUXCRi5Q@mail.gmail.com>
	<CAJ3xEMhg_CsCGA5_GkqTb0e=d=sSMJdbQG0gM8CoWvGP8PPGVw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tom@herbertland.com, ogerlitz@mellanox.com,
	john.r.fastabend@intel.com, netdev@vger.kernel.org,
	amirv@mellanox.com, idos@mellanox.com
To: gerlitz.or@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37211 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750950AbbCPTu0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Mar 2015 15:50:26 -0400
In-Reply-To: <CAJ3xEMhg_CsCGA5_GkqTb0e=d=sSMJdbQG0gM8CoWvGP8PPGVw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Or Gerlitz <gerlitz.or@gmail.com>
Date: Sun, 15 Mar 2015 23:10:25 +0200

> On Sun, Mar 15, 2015 at 7:08 PM, Tom Herbert <tom@herbertland.com> wrote:
>> On Sun, Mar 15, 2015 at 6:03 AM, Or Gerlitz <ogerlitz@mellanox.com> wrote:
>>> Add the ability to set a max-rate limitation for TX queues.
>>> The attribute name is maxrate and the units are Mbs, to make
>>> it similar to the existing max-rate limitation knobs (ETS and
>>> SRIOV ndo calls).
> 
>> Guaranteed rate is often defined in conjunction with maximum rate. It
>> might be nice to add a parameter for that to the ndo function in
>> anticipation of someone supporting that also.
> 
> I see -- so do we really want both from day one...? if this is the
> case, I can add that to the ndo with the value of 0 means no limit for
> maxrate and no guarantee for minrate

We can do this later.
