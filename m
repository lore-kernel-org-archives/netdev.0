From: Gabriel C <nix.or.die@googlemail.com>
Subject: Re: 2.6.23-rc2-mm2
Date: Fri, 10 Aug 2007 18:37:35 +0200
Message-ID: <46BC944F.9020801@googlemail.com>
References: <20070809224254.11f42716.akpm@linux-foundation.org> <46BC8F71.3070006@googlemail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>,
	linux-kernel@vger.kernel.org,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Netdev <netdev@vger.kernel.org>, coreteam@netfilter.org
To: Michal Piotrowski <michal.k.k.piotrowski@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.190]:7565 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S936408AbXHJQje (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Aug 2007 12:39:34 -0400
Received: by nf-out-0910.google.com with SMTP id g13so281220nfb
        for <netdev@vger.kernel.org>; Fri, 10 Aug 2007 09:39:32 -0700 (PDT)
In-Reply-To: <46BC8F71.3070006@googlemail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Michal Piotrowski wrote:
> Andrew Morton pisze:
>> ftp://ftp.kernel.org/pub/linux/kernel/people/akpm/patches/2.6/2.6.23-rc2/2.6.23-rc2-mm2/
>>
> 
> Yet another sysctl table check failed
> 
> [   88.949055] Netfilter messages via NETLINK v0.30.
> [   89.485399] nf_conntrack version 0.5.0 (16384 buckets, 65536 max)
> [   89.491892] sysctl table check failed: /net/netfilter/nf_conntrack_generic_timeout .3.19.13 Missing strategy
> [   89.558178] xt_state: Unknown symbol nf_conntrack_untracked
> [   89.563942] xt_state: Unknown symbol nf_ct_l3proto_module_put
> [   89.569870] xt_state: Unknown symbol nf_ct_l3proto_try_module_get
> [   90.852319] NET: Registered protocol family 17
>

And maybe this ?

http://lkml.org/lkml/2007/8/10/112

> Regards,
> Michal
> 

Gabriel
