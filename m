From: Tom Herbert <tom@herbertland.com>
Subject: Re: ipsec impact on performance
Date: Wed, 2 Dec 2015 13:44:20 -0800
Message-ID: <CALx6S36gcbJRJOTdUhgZGVbe4YzBeuBgv105kXLMyDSBBQ_56Q@mail.gmail.com>
References: <20151201175953.GC21252@oracle.com>
	<CALx6S35uLqbuJTAFLMeT-BcyZw_fksz+7BkS=Nt7_3-nYMHF2A@mail.gmail.com>
	<20151201183720.GE21252@oracle.com>
	<063D6719AE5E284EB5DD2968C1650D6D1CBE0ED7@AcuExch.aculab.com>
	<20151202121156.GK23178@oracle.com>
	<063D6719AE5E284EB5DD2968C1650D6D1CBE0F39@AcuExch.aculab.com>
	<20151202205028.GB15262@oracle.com>
	<CALx6S34yqw_vJ+r21Br9O7y5NqzvA264ot7=GBTHe=FxWqh=AQ@mail.gmail.com>
	<20151202211201.GD15262@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Laight <David.Laight@aculab.com>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	"linux-crypto@vger.kernel.org" <linux-crypto@vger.kernel.org>,
	Rick Jones <rick.jones2@hpe.com>
To: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f173.google.com ([209.85.223.173]:35215 "EHLO
	mail-io0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752038AbbLBVoV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Dec 2015 16:44:21 -0500
Received: by ioc74 with SMTP id 74so60681786ioc.2
        for <netdev@vger.kernel.org>; Wed, 02 Dec 2015 13:44:20 -0800 (PST)
In-Reply-To: <20151202211201.GD15262@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Dec 2, 2015 at 1:12 PM, Sowmini Varadhan
<sowmini.varadhan@oracle.com> wrote:
> On (12/02/15 13:07), Tom Herbert wrote:
>> That's easy enough to add to flow dissector, but is SPI really
>> intended to be used an L4 entropy value? We would need to consider the
>
> yes. To quote https://en.wikipedia.org/wiki/Security_Parameter_Index
> "This works like port numbers in TCP and UDP connections. What it means
>  is that there could be different SAs used to provide security to one
>  connection. An SA could therefore act as a set of rules."
>
>> effects of running multiple TCP connections over an IPsec. Also, you
>> might want to try IPv6, the flow label should provide a good L4 hash
>> for RPS/RFS, it would be interesting to see what the effects are with
>> IPsec processing. (ESP/UDP could also if RSS/ECMP is critical)
>
> IPv6 would be an interesting academic exercise, but it's going
> to be a while before we get RDS-TCP to go over IPv6.
>
Huh? Who said anything about RDS-TCP? I thought you were trying to
improve IPsec performance...
