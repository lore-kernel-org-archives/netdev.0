From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [net-next PATCH v3 00/12] Flow API
Date: Thu, 22 Jan 2015 16:48:40 +0100
Message-ID: <20150122154840.GC1863@nanopsycho.orion>
References: <20150120202404.1741.8658.stgit@nitbit.x32>
 <20150122125246.GA4486@salvia>
 <20150122133713.GA25797@casper.infradead.org>
 <20150122140022.GA5674@salvia>
 <54C11094.2000807@mojatatu.com>
 <20150122151316.GB25797@casper.infradead.org>
 <54C11703.7030702@mojatatu.com>
 <20150122153727.GC25797@casper.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jamal Hadi Salim <jhs@mojatatu.com>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	John Fastabend <john.fastabend@gmail.com>,
	simon.horman@netronome.com, sfeldma@gmail.com,
	netdev@vger.kernel.org, davem@davemloft.net, gerlitz.or@gmail.com,
	andy@greyhouse.net, ast@plumgrid.com
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f177.google.com ([209.85.212.177]:64466 "EHLO
	mail-wi0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751901AbbAVPsn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Jan 2015 10:48:43 -0500
Received: by mail-wi0-f177.google.com with SMTP id r20so4308529wiv.4
        for <netdev@vger.kernel.org>; Thu, 22 Jan 2015 07:48:42 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20150122153727.GC25797@casper.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thu, Jan 22, 2015 at 04:37:27PM CET, tgraf@suug.ch wrote:
>On 01/22/15 at 10:28am, Jamal Hadi Salim wrote:
>> On 01/22/15 10:13, Thomas Graf wrote:
>> 
>> >I don't follow this. John's proposal allows to decide on a case by
>> >case basis what we want to export. Just like with ethtool or
>> >RTNETLINK. There is no direct access to hardware. A user can only
>> >configure what is being exposed by the kernel.
>> >
>> 
>> So if i am a vendor with my own driver, I can expose whatever i want.
>
>No. We will reject any driver change attempting to do so on this
>list.

That is not 100%, on contrary. If the infrastructure would be made to
explicitly disallow that kind of behaviour, it would be much safer.


>
>This is the whole point of this: Coming up with a model that allows
>to describe capabilities and offer flow programming capabilities
>in a Vendor neutral way. A "push_vlan" or "pop_vlan" action will work
>with any driver that supports it.
