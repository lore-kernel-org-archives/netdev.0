From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [PATCH] NET: Add TCP connection abort IOCTL
Date: Fri, 30 Mar 2007 11:33:32 -0700
Message-ID: <460D57FC.6080007@linux-foundation.org>
References: <20070327214754.GA11677@dag-work>	 <20070327.153025.45876618.davem@davemloft.net>	 <46d726f90703290756k1894b0aal8df85d46d8c2a25e@mail.gmail.com>	 <20070329.114139.55510589.davem@davemloft.net>	 <460C6348.5030904@osdl.org> <46d726f90703300810q619e8bbmb5b15a58ff37bbed@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, dagriego@gmail.com,
	netdev@vger.kernel.org
To: Predrag Hodoba <predrag.hodoba@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:46794 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751286AbXC3Sdh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 30 Mar 2007 14:33:37 -0400
In-Reply-To: <46d726f90703300810q619e8bbmb5b15a58ff37bbed@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Predrag Hodoba wrote:
> On 30/03/07, Stephen Hemminger <shemminger@osdl.org> wrote:
>> David Miller wrote:
>> >
>> > Something being in the CGL specification is to me exactly a great
>> > reason NOT to add it.  That specification is so full of garbage it's
>> > unbelievable.
>> >
>> > Thanks, you've given me one more reason not to even remotely consider
>> > adding this feature.
>> >
>> Agreed, CGL is a vendor driven group that has always wanted to replicate
>> proprietary misfeatures onto Linux.  There is a real requirement to
>> provide high availability but there should be no requirement to 
>> implement
>> the solution in the same crap way as legacy Unix.
>
> OK, let's put aside CGL and legacy Unices.
>
> Still, I don't see how the case I mentioned can easily be handled.
> (The case being - effective clean up of all affected client TCP
> connections, following failover of the server IP address from active
> to passive node in a highly available cluster).
Why clean them up? The client connections will timeout and they can
reconnect. Actively killing them early does nothing helpful. Just like
the CGL requirement for forced unmount, the forced operation introduces
a whole bunch of race conditions and shared file descriptor problems.

