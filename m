From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [net-next PATCH v2 1/5] introduce IFE action
Date: Wed, 24 Feb 2016 07:39:25 -0500
Message-ID: <56CDA47D.30907@mojatatu.com>
References: <1456231760-2513-1-git-send-email-jhs@emojatatu.com>
 <1456231760-2513-2-git-send-email-jhs@emojatatu.com>
 <56CC5F73.9080201@iogearbox.net> <56CC6F3E.6000106@mojatatu.com>
 <56CC84F2.8030909@iogearbox.net> <20160224054557.GA12134@vergenet.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	xiyou.wangcong@gmail.com, alexei.starovoitov@gmail.com,
	john.fastabend@gmail.com, dj@verizon.com
To: Simon Horman <simon.horman@netronome.com>,
	Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f180.google.com ([209.85.223.180]:35046 "EHLO
	mail-io0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752370AbcBXMjs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Feb 2016 07:39:48 -0500
Received: by mail-io0-f180.google.com with SMTP id g203so35757600iof.2
        for <netdev@vger.kernel.org>; Wed, 24 Feb 2016 04:39:46 -0800 (PST)
In-Reply-To: <20160224054557.GA12134@vergenet.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-02-24 12:46 AM, Simon Horman wrote:
> On Tue, Feb 23, 2016 at 05:12:34PM +0100, Daniel Borkmann wrote:


>  From my point of view the test should be weather the encapsulation might
> reasonably be expected to be used outside of the context of tc. If so then
> it makes sense to use a netdev to allow sharing of infrastructure between
> different kernel components.
>
> I suspect the answer to that question is no and thus IMHO a netdev would be
> nice to have rather than compelling.
>
> With regards to overhead of netdevs: I think that could be mitigated to
> some extent by using LWT or some other metadata-based approach to allow a
> single netdev to be use by multiple tc action instances.

We actually have a use case where we offload this thing into
an embedded NIC.

In any case it doesnt make much sense to use a netdev for reasons i
specified. Just like it doesnt make sense when i want a policy which
pushes or pops vlans or vxlans to use netdevs either.
Yes it quacks like a duck(i.e has receive) and walks like a duck(has
stats) but it looks like an ostrich;->

cheers,
jamal
