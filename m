From: David Miller <davem@davemloft.net>
Subject: Re: Backport bpf: try harder on clones when writing into skb?
 [Commit: 3697649ff29e0f647565eed04b27a7779c646a22]
Date: Tue, 05 Jul 2016 20:47:55 -0700 (PDT)
Message-ID: <20160705.204755.193524893150572527.davem@davemloft.net>
References: <CAMp4zn-MNgqJ1Xzm8JO529=LVyB71bdYaUm0FqyNCMx4Hf+xSA@mail.gmail.com>
	<20160706021649.GA82976@ast-mbp.thefacebook.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sargun@sargun.me, netdev@vger.kernel.org, daniel@iogearbox.net
To: alexei.starovoitov@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:48002 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751271AbcGFDr6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jul 2016 23:47:58 -0400
In-Reply-To: <20160706021649.GA82976@ast-mbp.thefacebook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Date: Tue, 5 Jul 2016 19:16:51 -0700

> On Tue, Jul 05, 2016 at 08:35:18AM -0700, Sargun Dhillon wrote:
>> Does it make sense to backport
>> 3697649ff29e0f647565eed04b27a7779c646a22 from 4.6 to the longterm
>> (4.4) release? I can trivially recreate the issue represented by
>> 3697649ff29e0f647565eed04b27a7779c646a22 by attaching a eBPF filter
>> that clones an ingress ICMP packet, and then tries to set the
>> destination MAC address.
>> 
>> It seems like the patch applies cleanly to 4.4. I cherry-picked it,
>> and rebuilt my kernel, and at least in the trivial test case passes.
> 
> Makes sense to me, especially since it's lts.
> Daniel, thoughts?

I'll queued this up for 4.4 -stable.
