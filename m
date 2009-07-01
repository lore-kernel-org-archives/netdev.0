From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] bridge: make bridge-nf-call-*tables default configurable
Date: Wed, 01 Jul 2009 12:51:06 +0200
Message-ID: <4A4B3F9A.9060105@trash.net>
References: <1246379267.3749.42.camel@blaa>	 <20090630.201630.134200035.davem@davemloft.net> <1246445158.598.30.camel@blaa>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	herbert@gondor.apana.org.au
To: Mark McLoughlin <markmc@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:55033 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754849AbZGAKvM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Jul 2009 06:51:12 -0400
In-Reply-To: <1246445158.598.30.camel@blaa>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mark McLoughlin wrote:
> On Tue, 2009-06-30 at 20:16 -0700, David Miller wrote:
>> From: Mark McLoughlin <markmc@redhat.com>
>> Date: Tue, 30 Jun 2009 17:27:47 +0100
>>
>>> For these reasons, it makes sense to allow distributions to disable
>>> netfilter on the bridge by default and require those specialized users
>>> to enable it explicitly via sysctl.
>> I heard that distributions ship some file, what's it called...
>> something like /etc/sysctl.conf :-)
>>
>> Really, if someone thinkgs the default stinks and dists don't like it
>> for their users, they can use sysctl.conf to set it how they please.
> 
> If upstream agrees the default stinks, then upstream could start making
> moves towards rectifying it :-)
> 
> I like Patrick's idea of adding it to feature-removal-schedule
> 
>> Notwithstanding that changing this default can break working
>> setups and scripts.  Yes they can "change", but they were just
>> (rightly) using the kernel as it came to them.
> 
> Yep, that's a valid concern.
> 
> Weighing up the impact on the small number of people who use it versus
> the ongoing impact on everyone else, I think it's best to make the
> change.

I agree, this has already caused an endless amount of problems for
users due to the unexpected behaviour and, in some cases, bugs.

Dave's point is certainly valid as well, until we change the defaults,
distributions can use sysctl.conf. But I think we should move towards
changing the defaults.
