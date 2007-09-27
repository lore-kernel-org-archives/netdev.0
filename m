From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH 3/4] net ipv4: When possible test for IFF_LOOPBACK and not dev == loopback_dev
Date: Thu, 27 Sep 2007 10:10:27 -0600
Message-ID: <m18x6sm6mk.fsf@ebiederm.dsl.xmission.com>
References: <m1ps05rnjv.fsf@ebiederm.dsl.xmission.com>
	<m1ir5xrngu.fsf@ebiederm.dsl.xmission.com>
	<m1bqbprnc2.fsf_-_@ebiederm.dsl.xmission.com>
	<46FB873C.6060200@fr.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	Linux Containers <containers@lists.osdl.org>,
	netdev@vger.kernel.org, urs@isnogud.escape.de
To: Daniel Lezcano <dlezcano@fr.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ebiederm.dsl.xmission.com ([166.70.28.69]:36136 "EHLO
	ebiederm.dsl.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753992AbXI0QLN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Sep 2007 12:11:13 -0400
In-Reply-To: <46FB873C.6060200@fr.ibm.com> (Daniel Lezcano's message of "Thu,
	27 Sep 2007 12:34:36 +0200")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Daniel Lezcano <dlezcano@fr.ibm.com> writes:

> Eric W. Biederman wrote:
>> Now that multiple loopback devices are becoming possible it makes
>> the code a little cleaner and more maintainable to test if a deivice
>> is th a loopback device by testing dev->flags & IFF_LOOPBACK instead
>> of dev == loopback_dev.
>>
>> Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
>
>
> Urs Thuermann posted the patch:
>
> 	[PATCH 5/7] CAN: Add virtual CAN netdevice driver
>
> This network driver set its flag to IFF_LOOPBACK for testing.
> Is it possible this can be a collision with your patch ?

I have brought it up on that thread.  As best as I tell the CAN usage
of IFF_LOOPBACK will be a problem even without my patch.  Assuming
something other then the CAN layer will see the CAN devices.

The CAN documentations IFF_LOOPBACK should be set on all CAN devices.

It seems that the people who want high performance predictable CAN
don't want this and the people who want something they can trace
easily want this.

It sounds to me like CAN routers don't exist.

Anyway hopefully that usage can be resolved as that code is reviewed,
and made ready to merge.

Eric
