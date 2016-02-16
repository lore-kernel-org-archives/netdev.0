From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] lwt: fix rx checksum setting for lwt devices
 tunneling over ipv6
Date: Tue, 16 Feb 2016 16:37:50 -0500 (EST)
Message-ID: <20160216.163750.631056934356631230.davem@davemloft.net>
References: <CALx6S34k2Hz-kBeTZ9brLZDCp1tU9nUMZN6V9zhoqmEU3+TR_A@mail.gmail.com>
	<20160216.155332.104228217048445468.davem@davemloft.net>
	<CALx6S34AsmKy57msp85o0_Y8KKM_4iQN9Bx=nfsE3gs6RP9t2A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tgraf@suug.ch, pabeni@redhat.com, jbenc@redhat.com,
	pshelar@nicira.com, jesse@kernel.org, netdev@vger.kernel.org
To: tom@herbertland.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40454 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932865AbcBPVhy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Feb 2016 16:37:54 -0500
In-Reply-To: <CALx6S34AsmKy57msp85o0_Y8KKM_4iQN9Bx=nfsE3gs6RP9t2A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Herbert <tom@herbertland.com>
Date: Tue, 16 Feb 2016 13:31:34 -0800

> On Feb 16, 2016 12:53 PM, "David Miller" <davem@davemloft.net> wrote:
>> And practically speaking we disappear from the internet for VXLAN tunnel
>> endpoints implementing the VXLAN spec properly.
>>
>> That's not going to help anyone at all.
> 
> A lot of effort has gone into defining the constraints for using zero udp6
> csum (look at Rfc6935 and rfc6936). Just because Cisco unilaterally decided
> the csum is a nuisance, doesn't mean it can be ignored. No udp6 csum
> increases chance of misdelivery, which in multitenant nv is really bad.

People who review RFCs had ample opportunity to review the VXLAN RFC and
find this issue and fix it.

It slipped through and now we are stuck with it, just like we are stuck
with bad user facing kernel APIs.

Objecting now and voicing our objection by breaking interoperability
serves no useful purpose whatsoever.
