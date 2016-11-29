From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net-next] bpf: add test for the verifier equal logic bug
Date: Tue, 29 Nov 2016 21:23:59 +0100
Message-ID: <583DE3DF.5070507@iogearbox.net>
References: <1480440919-3252-1-git-send-email-jbacik@fb.com> <583DD1C0.1010209@iogearbox.net> <c2ea35d1-302c-671e-f976-9bb7ccf56197@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
To: Josef Bacik <jbacik@fb.com>, davem@davemloft.net,
        netdev@vger.kernel.org, ast@kernel.org, jannh@google.com,
        kernel-team@fb.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:33970 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756691AbcK2UYD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 29 Nov 2016 15:24:03 -0500
In-Reply-To: <c2ea35d1-302c-671e-f976-9bb7ccf56197@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/29/2016 08:50 PM, Josef Bacik wrote:
> On 11/29/2016 02:06 PM, Daniel Borkmann wrote:
>> On 11/29/2016 06:35 PM, Josef Bacik wrote:
>>> This is a test to verify that
>>>
>>> bpf: fix states equal logic for varlen access
>>>
>>> actually fixed the problem.  The problem was if the register we added to our map
>>> register was UNKNOWN in both the false and true branches and the only thing that
>>> changed was the range then we'd incorrectly assume that the true branch was
>>> valid, which it really wasnt.  This tests this case and properly fails without
>>> my fix in place and passes with it in place.
>>>
>>> Signed-off-by: Josef Bacik <jbacik@fb.com>
>>
>> Acked-by: Daniel Borkmann <daniel@iogearbox.net>
>>
>> Thanks a lot for the test case! They are always useful to have ... which
>> just reminds me: it seems we didn't add anything for f23cc643f9ba ("bpf:
>> fix range arithmetic for bpf map access"). ;-)
>
> I was hoping you wouldn't notice ;).  I'll add one in the next couple of days. Thanks,

Awesome, thanks a lot! :-)
