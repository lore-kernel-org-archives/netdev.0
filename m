From: Or Gerlitz <gerlitz.or@gmail.com>
Subject: Re: [PATCH net-next V1 0/3] net/mlx4_core: Allow setting init-time
 device specific parameters
Date: Thu, 12 Mar 2015 22:51:32 +0200
Message-ID: <CAJ3xEMibyF7B3m2nrgBE8Zaj+oH+cJ+MH_61QfvO-ge=3CWYkQ@mail.gmail.com>
References: <CAJL1qvHP0cLRVf53J9MuJrYCJLjE=mzEU70JofJ8zH_Yf-O16g@mail.gmail.com>
	<20150312.140505.1685428263314887570.davem@davemloft.net>
	<CAJL1qvHOFzAU=ciTR2A3AgoX622+c5wDYLEC07OaGwOZsC6jxA@mail.gmail.com>
	<20150312.153130.1372889580818723770.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: hadarh@dev.mellanox.co.il,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Amir Vadai <amirv@mellanox.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Hadar Hen Zion <hadarh@mellanox.com>,
	Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	"talal@mellanox.com" <talal@mellanox.com>,
	Shannon Nelson <shannon.nelson@intel.com>,
	Doug Ledford <dledford@redhat.com>, greearb@candelatech.com,
	Greg Rose <gregory.v.rose@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	john.ronciak@intel.com
To: David Miller <davem@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f44.google.com ([209.85.218.44]:46285 "EHLO
	mail-oi0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754060AbbCLUvd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Mar 2015 16:51:33 -0400
Received: by oiga141 with SMTP id a141so16919487oig.13
        for <netdev@vger.kernel.org>; Thu, 12 Mar 2015 13:51:32 -0700 (PDT)
In-Reply-To: <20150312.153130.1372889580818723770.davem@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 12, 2015 at 9:31 PM, David Miller <davem@redhat.com> wrote:
> From: Hadar Hen Zion <hadarh@dev.mellanox.co.il>
>> On Thu, Mar 12, 2015 at 8:05 PM, David Miller <davem@davemloft.net> wrote:
>>> From: Hadar Hen Zion <hadarh@dev.mellanox.co.il>
>>>> On Wed, Mar 11, 2015 at 7:14 PM, David Miller <davem@davemloft.net>

[...]
>>>>> These textual interfaces are arbitrary, and you are choosing it only
>>>>> because you cannot come up with a more reasonable scheme,

[...]
>>>> Is a scheme based on netlink will be acceptable by you?

>>> A portable, well typed, interface that other vendors could use if their
>>> hardware had similar features would be acceptable.

>> Do you mean an interface implementation that reminds the ethtool
>> private flags scheme but implemented through netlink, allows
>> configuration without a netdevice and more flexibility?

> I mean exactly what I said, neither more nor less.

Hey Dave, we're trying to see we understand... already two
implementations in a row weren't accepted, so now before doing the 3rd
one, we want to better align.

So, it has to be non-textual, portable, well typed and one that can be
used by other vendors too. We are talking that could be used for
multiple vendor driver to configure few proprietary HW initialization
params. So how about a scheme based on key/value pairs carried over
netlink messages?

Or.
