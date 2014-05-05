From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2] net: filter: add insn for loading internal
 transport header offset
Date: Mon, 05 May 2014 15:12:00 -0400 (EDT)
Message-ID: <20140505.151200.705079679797479652.davem@davemloft.net>
References: <CA+ZOOTP88BJ-keuR5NznCgbDVPyzugWkdsVYjKkk5yGOBbkddQ@mail.gmail.com>
	<20140502.225252.1865694187680020950.davem@davemloft.net>
	<CA+ZOOTNQJ59VrFhrtGT7EzhL7u0FnupuwOLqv-rJ0jQi2CP8Jg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: edumazet@google.com, dborkman@redhat.com, ast@plumgrid.com,
	netdev@vger.kernel.org
To: chema@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60664 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751771AbaEETMF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 May 2014 15:12:05 -0400
In-Reply-To: <CA+ZOOTNQJ59VrFhrtGT7EzhL7u0FnupuwOLqv-rJ0jQi2CP8Jg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Chema Gonzalez <chema@google.com>
Date: Mon, 5 May 2014 11:42:00 -0700

> On Fri, May 2, 2014 at 7:52 PM, David Miller <davem@davemloft.net> wrote:
>> We can probably add an extension to AF_PACKET which provides the flow
>> key at the end of the tpacket3_hdr if a certain socket option is set.
>>
>> That would provide the transport header as well as a side effect, and
>> be much more powerful and efficient than this particular BPF
>> instruction.
> I'm not sure whether I follow this. The goal is to be able to access
> the inner-most headers inside BPF, not in userland by calling
> getsockopt().

You're missing my entire point.

You can use AF_PACKET mmap() rings and in those ring entries all of the
flow dissection information can be put in the ring entry headers before
the packet contents.  Ports, header offsets, everything.
