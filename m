From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] openvswitch: Fix L4 checksum handling when dealing
 with IP fragments
Date: Mon, 10 Aug 2015 11:23:28 -0700 (PDT)
Message-ID: <20150810.112328.309806698983159152.davem@davemloft.net>
References: <20150803165654.GA16892@google.com>
	<20150803.140328.574050334230752525.davem@davemloft.net>
	<20150810174316.GA19574@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: pshelar@nicira.com, netdev@vger.kernel.org, dev@openvswitch.org,
	linux-kernel@vger.kernel.org
To: ggriffin.kernel@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150810174316.GA19574@google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Glenn Griffin <ggriffin.kernel@gmail.com>
Date: Mon, 10 Aug 2015 10:43:16 -0700

> On Mon, Aug 03, 2015 at 02:03:28PM -0700, David Miller wrote:
>> From: Glenn Griffin <ggriffin.kernel@gmail.com>
>> Date: Mon, 3 Aug 2015 09:56:54 -0700
>> 
>> > openvswitch modifies the L4 checksum of a packet when modifying
>> > the ip address. When an IP packet is fragmented only the first
>> > fragment contains an L4 header and checksum. Prior to this change
>> > openvswitch would modify all fragments, modifying application data
>> > in non-first fragments, causing checksum failures in the
>> > reassembled packet.
>> > 
>> > Signed-off-by: Glenn Griffin <ggriffin.kernel@gmail.com>
>> > ---
>> > Changes in v2:
>> >   - Compare frag_off in network byte order rather than host byte order
>> 
>> Applied and queued up for -stable.
> 
> I noticed this change didn't seem to make it into 4.2-rc6. I'm not too
> familiar with the release schedule so wasn't sure if that was expected
> or an oversight. Will this remain queued up until the 4.3 merge window
> opens?

It's in my 'net' tree and will be pushed to Linus's tree at a time that I
deem appropriate.  Usually I try to push to Linus one every week or so,
in order for changes to soak and get tested in my tree before they get
pushed to his.
