From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: 2.6.23-rc2-mm2
Date: Fri, 10 Aug 2007 11:33:41 -0600
Message-ID: <m1fy2rxpje.fsf@ebiederm.dsl.xmission.com>
References: <20070809224254.11f42716.akpm@linux-foundation.org>
	<46BC8F71.3070006@googlemail.com> <46BC944F.9020801@googlemail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Michal Piotrowski <michal.k.k.piotrowski@gmail.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	linux-kernel@vger.kernel.org, Netdev <netdev@vger.kernel.org>,
	coreteam@netfilter.org
To: Gabriel C <nix.or.die@googlemail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ebiederm.dsl.xmission.com ([166.70.28.69]:36471 "EHLO
	ebiederm.dsl.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752389AbXHJRe1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Aug 2007 13:34:27 -0400
In-Reply-To: <46BC944F.9020801@googlemail.com> (Gabriel C.'s message of "Fri,
	10 Aug 2007 18:37:35 +0200")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Gabriel C <nix.or.die@googlemail.com> writes:

> Michal Piotrowski wrote:
>> Andrew Morton pisze:
>>>
> ftp://ftp.kernel.org/pub/linux/kernel/people/akpm/patches/2.6/2.6.23-rc2/2.6.23-rc2-mm2/
>>>
>> 
>> Yet another sysctl table check failed
>> 
>> [   88.949055] Netfilter messages via NETLINK v0.30.
>> [   89.485399] nf_conntrack version 0.5.0 (16384 buckets, 65536 max)
>> [ 89.491892] sysctl table check failed:
> /net/netfilter/nf_conntrack_generic_timeout .3.19.13 Missing strategy
>> [   89.558178] xt_state: Unknown symbol nf_conntrack_untracked
>> [   89.563942] xt_state: Unknown symbol nf_ct_l3proto_module_put
>> [   89.569870] xt_state: Unknown symbol nf_ct_l3proto_try_module_get
>> [   90.852319] NET: Registered protocol family 17
>>
>
> And maybe this ?

Could be.

sysctl table check failure looks legitimate.
At a quick skim I can't tell for certain if failure to register the
sysctl table will keep the module from loading but it might.

It looks like another canidate on the pile of kill the broken
binary sysctl.

Eric
