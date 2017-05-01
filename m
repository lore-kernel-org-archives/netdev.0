From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v4 binutils] Add BPF support to binutils...
Date: Mon, 01 May 2017 14:50:11 -0400 (EDT)
Message-ID: <20170501.145011.2010615531122694032.davem@davemloft.net>
References: <f7ttw541ohz.fsf@redhat.com>
        <20170501.135202.2175412915689459473.davem@davemloft.net>
        <f7t37coxvys.fsf@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ast@fb.com, daniel@iogearbox.net, netdev@vger.kernel.org,
        xdp-newbies@vger.kernel.org
To: aconole@bytheb.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:35942 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750816AbdEASuN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 1 May 2017 14:50:13 -0400
In-Reply-To: <f7t37coxvys.fsf@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Aaron Conole <aconole@bytheb.org>
Date: Mon, 01 May 2017 14:39:39 -0400

> David Miller <davem@davemloft.net> writes:
> 
>> From: Aaron Conole <aconole@bytheb.org>
>> Date: Mon, 01 May 2017 13:22:00 -0400
>>
>>> x86-64:
>>>   Running /home/aconole/git/binutils-gdb/gas/testsuite/gas/bpf/bpf.exp ...
>>>   FAIL: jump
>>>   FAIL: call
>>>   FAIL: imm64a
>>>   Running /home/aconole/git/binutils-gdb/gas/testsuite/gas/cfi/cfi.exp ...
>>
>> I cannot reproduce this, can you show what it says in the:
>>
>> 	/home/aconole/git/binutils-gdb/gas/testsuite/gas.log
>>
>> file near the "FAIL" cases?
> 
> Executing on host: sh -c {/home/aconole/git/binutils-gdb/gas/testsuite/../../binutils/objdump  -dr dump.o >dump.out 2>gas.stderr}  /dev/null  (timeout = 300)
> spawn [open ...]
> regexp_diff match failure
> regexp "^ 108:	95 00 00 00 00 00 00 00 	exit$"
> line   " 108:	95 00 00 00 00 00 00 00 	exit	"
> FAIL: jump
> 
> 
> Same style of error for call and imm64a.  After reverting and then
> re-applying your patch, the FAILs all go away, so I must have broken
> these files somehow.  Sorry for the false alarm.

Great, thanks for checking.
