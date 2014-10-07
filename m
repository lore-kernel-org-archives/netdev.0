From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: Add ndo_gso_check
Date: Tue, 07 Oct 2014 16:32:39 -0400 (EDT)
Message-ID: <20141007.163239.157997964784151921.davem@davemloft.net>
References: <CAADnVQJUhEmER7C_OOs0dM_mD8REbYT89SG1dfu2b79AUn9eow@mail.gmail.com>
	<20141007.144752.657165589422333613.davem@davemloft.net>
	<CAADnVQKKv43aBFCCaEypAosCf+8K64A2oyYEtxw4jQqY0npV5g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: therbert@google.com, jesse@nicira.com, gerlitz.or@gmail.com,
	alexander.h.duyck@intel.com, john.r.fastabend@intel.com,
	jeffrey.t.kirsher@intel.com, netdev@vger.kernel.org, tgraf@suug.ch,
	pshelar@nicira.com, azhou@nicira.com
To: alexei.starovoitov@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48388 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751712AbaJGUcm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Oct 2014 16:32:42 -0400
In-Reply-To: <CAADnVQKKv43aBFCCaEypAosCf+8K64A2oyYEtxw4jQqY0npV5g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Date: Tue, 7 Oct 2014 13:28:01 -0700

> On Tue, Oct 7, 2014 at 11:47 AM, David Miller <davem@davemloft.net> wrote:
>>
>> I am totally against boolean "yes/no" protocol specific checksum
>> validation by HW.
>>
>> It's not faster.  You have to look at the pseudo-header and bring it into
>> the CPU cache _anyways_, so negating it and 2's complementing it into
>> the CHECKSUM_COMPLETE value for validation is free.
>>
>> There is no performance advantage whatsoever to use another checksumming
>> scheme.
> 
> ok, forget faster/slower argument for a second.
> Why is it a bad thing to have HW verifying checksums?

Because you have to change the damn hardware and/or firmware for every
new protocol.

COMPLETE works on _EVERYTHING_ we could ever invent.
