From: Alexei Starovoitov <ast@fb.com>
Subject: Re: [PATCH net] bpf: add get_next_key callback to LPM map
Date: Sun, 5 Mar 2017 10:58:00 -0800
Message-ID: <58BC5FB8.4090507@fb.com>
References: <1488735668-2296008-1-git-send-email-ast@fb.com>
 <20170305.104413.1645369685777679734.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <daniel@iogearbox.net>, <daniel@zonque.org>, <dvyukov@google.com>,
        <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:59749 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1750770AbdCETmd (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 5 Mar 2017 14:42:33 -0500
In-Reply-To: <20170305.104413.1645369685777679734.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 3/5/17 10:44 AM, David Miller wrote:
> From: Alexei Starovoitov <ast@fb.com>
> Date: Sun, 5 Mar 2017 09:41:08 -0800
>
>> map_get_next_key callback is mandatory. Supply dummy handler.
>>
>> Fixes: b95a5c4db09b ("bpf: add a longest prefix match trie map implementation")
>> Reported-by: Dmitry Vyukov <dvyukov@google.com>
>> Signed-off-by: Alexei Starovoitov <ast@kernel.org>
>
> Wouldn't it be more appropriate to provide a proper DFS ordered
> traversal rather than return an error code?

yes. of course. This is quick fix for 'net'.
That's why the error code is ENOTSUPP with meaning that
it's not supported right now and will be supported in the future.
