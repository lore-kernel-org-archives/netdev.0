From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH net-next 0/3] s390/bpf: implement bpf_tail_call JIT support
Date: Mon, 01 Jun 2015 22:50:56 -0700
Message-ID: <556D4440.5010503@plumgrid.com>
References: <1433007731-16992-1-git-send-email-ast@plumgrid.com> <20150531.213931.282168647572228489.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: holzheu@linux.vnet.ibm.com, schwidefsky@de.ibm.com,
	heiko.carstens@de.ibm.com, daniel@iogearbox.net,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f54.google.com ([209.85.220.54]:35487 "EHLO
	mail-pa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755785AbbFBFu7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Jun 2015 01:50:59 -0400
Received: by padjw17 with SMTP id jw17so53569878pad.2
        for <netdev@vger.kernel.org>; Mon, 01 Jun 2015 22:50:58 -0700 (PDT)
In-Reply-To: <20150531.213931.282168647572228489.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 5/31/15 9:39 PM, David Miller wrote:
> From: Alexei Starovoitov <ast@plumgrid.com>
> Date: Sat, 30 May 2015 10:42:08 -0700
>
>> This set is for net-next tree.
>>
>> Patch 3 adds bpf_tail_call() support for s390x JIT. It has
>> a dependency on patches 1 and 2 that will also be submitted
>> to stable via Martin Schwidefsky.
>
> In this kind of scenerio, patches #1 and #2 should go via my
> tree (somehow), and then when I next merge 'net' into 'net-next'
> you can submit patch #3.

all makes sense. Just resubmitted #1 and #2 against 'net' with
proper 'Fixes' tag.
