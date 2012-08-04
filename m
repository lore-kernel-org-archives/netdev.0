From: "Eric W. Biederman" <ebiederm@xmission.com>
Subject: Re: [PATCH V2 09/12] net/eipoib: Add main driver functionality
Date: Sat, 04 Aug 2012 16:19:03 -0700
Message-ID: <31b6a1d6-3bc1-48ab-aeb5-b9755fae51d2@email.android.com>
References: <501C3527.6060809@mellanox.com> <20120803.143315.151094375569109262.davem@davemloft.net> <501C5328.4060301@mellanox.com> <20120803.163627.1867181085116225405.davem@davemloft.net> <CAJZOPZJ=WPXcEysh-2p+pmY7RJME24zySWHGzGYbOq9LKidvBA@mail.gmail.com> <CAJZOPZ+TJ7JLdvmh7a9mNAp0bujv0jQBG+5Aq9aU9MEVOJobeA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=UTF-8
Content-Transfer-Encoding: 8BIT
Cc: ali@mellanox.com, ogerlitz@mellanox.com, roland@kernel.org,
	netdev@vger.kernel.org, sean.hefty@intel.com, erezsh@mellanox.co.il
To: Or Gerlitz <or.gerlitz@gmail.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:58440 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754177Ab2HDXTR convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 4 Aug 2012 19:19:17 -0400
In-Reply-To: <CAJZOPZ+TJ7JLdvmh7a9mNAp0bujv0jQBG+5Aq9aU9MEVOJobeA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Or Gerlitz <or.gerlitz@gmail.com> wrote:

>On Sun, Aug 5, 2012 at 12:23 AM, Or Gerlitz <or.gerlitz@gmail.com>
>wrote:
>
>> The idea in eIPoIB was to allow IP apps running on VMs under a
>Para-Virtual set of
>> mind, e.g when the Linux PV networking stack comes into play, to use
>that stack w.o > modifying it. When looking on that, we thought so far
>so good, and went in the way
>> posted here. If reusing your last sentence... this driver provides a
>way for apps to use
>> the PV stack AND IB whilst using something familiar, like IPv4.
>
>OK, when I said the PV stack, I meant the portion of the PV stack
>which assumes Ethernet link layer, ofcourse... If someone uses routing
>they don't need this driver.
>
>Again, since the app only uses IP,  which is well defined, etc. the
>work done by the eipoib driver, didn't seem as hackish messing, so I'm
>again with that WW (Why/What) question from 5m ago.


Something is missing from your sentence. 

What is the alternative that you view as worse?

Juast as a point of information.  In general when bridging is desired but not possible people deploy proxy arp.

I completely fail to see how having the VM output to a tun interface and then routing that, would not be supported by current solutions.  I believe that is where VM solutions all started networking wise.  Outputting to an interface is needed to support interfaces like 802.11 where bridging frequently does not work.

Eric
