From: Gabriel C <nix.or.die@googlemail.com>
Subject: Re: 2.6.23-rc3-mm1
Date: Wed, 22 Aug 2007 19:01:50 +0200
Message-ID: <46CC6BFE.3020400@googlemail.com>
References: <20070822020648.5ea3a612.akpm@linux-foundation.org>	<46CC3B27.10604@googlemail.com> <20070822090953.78a3d90c.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev <netdev@vger.kernel.org>
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.188]:15953 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933032AbXHVRDO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Aug 2007 13:03:14 -0400
Received: by nf-out-0910.google.com with SMTP id g13so169275nfb
        for <netdev@vger.kernel.org>; Wed, 22 Aug 2007 10:03:11 -0700 (PDT)
In-Reply-To: <20070822090953.78a3d90c.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Andrew Morton wrote:
> On Wed, 22 Aug 2007 15:33:27 +0200 Gabriel C <nix.or.die@googlemail.com> wrote:
> 
>> ...
>>
>>  CC      arch/i386/boot/cpu.o
>>   CC      arch/i386/boot/cpucheck.o
>> WARNING: "div64_64" [net/netfilter/xt_connbytes.ko] has no CRC!
>>   CC      arch/i386/boot/edd.o
>>   AS      arch/i386/boot/header.o
>>   CC      arch/i386/boot/main.o
> 
> Yeah, I get that too.  I was hoping that someone who had a vague clue
> about what's causing it might fix it also.

Hmm.. I don't know ( added netdev to Cc ) I got one more :

...

WARNING: "div64_64" [net/ipv4/tcp_cubic.ko] has no CRC!

...

Btw when modprobing these the kernel gets tainted

...

[ 5498.536055] nf_conntrack version 0.5.0 (10240 buckets, 40960 max)
[ 5498.554844] xt_connbytes: no version for "div64_64" found: kernel tainted.

...


> 
>> ...
>>
>> config : http://194.231.229.228/kernel/mm/2.6.23-rc3-mm1/config
>> build-log: http://194.231.229.228/kernel/mm/2.6.23-rc3-mm1/build-log
>>
