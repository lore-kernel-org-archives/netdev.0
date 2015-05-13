From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH v2 net-next] test_bpf: add 173 new testcases for eBPF
Date: Tue, 12 May 2015 20:33:55 -0700
Message-ID: <5552C623.7060301@plumgrid.com>
References: <1431445096-13698-1-git-send-email-ast@plumgrid.com> <20150512.232310.389605215659991765.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: holzheu@linux.vnet.ibm.com, daniel@iogearbox.net,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f175.google.com ([209.85.192.175]:33575 "EHLO
	mail-pd0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933961AbbEMDdz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 May 2015 23:33:55 -0400
Received: by pdbnk13 with SMTP id nk13so36943431pdb.0
        for <netdev@vger.kernel.org>; Tue, 12 May 2015 20:33:55 -0700 (PDT)
In-Reply-To: <20150512.232310.389605215659991765.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 5/12/15 8:23 PM, David Miller wrote:
> From: Alexei Starovoitov <ast@plumgrid.com>
> Date: Tue, 12 May 2015 08:38:16 -0700
>
>> From: Michael Holzheu <holzheu@linux.vnet.ibm.com>
>>
>> add an exhaustive set of eBPF tests bringing total to:
>> test_bpf: Summary: 233 PASSED, 0 FAILED, [0/226 JIT'ed]
>>
>> Signed-off-by: Michael Holzheu <holzheu@linux.vnet.ibm.com>
>> Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>
>> Acked-by: Daniel Borkmann <daniel@iogearbox.net>
>> ---
>> V1->V2: removed double 'From', added 'Ack'
>>
>> these tests found div64 bug in interpreter (already fixed)
>> and another cpu_to_be16 bug in x64 JIT (fix is being worked on).
>
> Sorry, I applied V1 of this, and in fact I removed the double From:
> when I applied it.
>
> I hope this is ok.

yes. thanks a lot!
