From: Josef Bacik <jbacik@fb.com>
Subject: Re: [PATCH net-next] bpf: add test for the verifier equal logic bug
Date: Tue, 29 Nov 2016 14:50:15 -0500
Message-ID: <c2ea35d1-302c-671e-f976-9bb7ccf56197@fb.com>
References: <1480440919-3252-1-git-send-email-jbacik@fb.com>
 <583DD1C0.1010209@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
To: Daniel Borkmann <daniel@iogearbox.net>, <davem@davemloft.net>,
        <netdev@vger.kernel.org>, <ast@kernel.org>, <jannh@google.com>,
        <kernel-team@fb.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:58516 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1751148AbcK2TwC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 29 Nov 2016 14:52:02 -0500
In-Reply-To: <583DD1C0.1010209@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/29/2016 02:06 PM, Daniel Borkmann wrote:
> On 11/29/2016 06:35 PM, Josef Bacik wrote:
>> This is a test to verify that
>>
>> bpf: fix states equal logic for varlen access
>>
>> actually fixed the problem.  The problem was if the register we added to our map
>> register was UNKNOWN in both the false and true branches and the only thing that
>> changed was the range then we'd incorrectly assume that the true branch was
>> valid, which it really wasnt.  This tests this case and properly fails without
>> my fix in place and passes with it in place.
>>
>> Signed-off-by: Josef Bacik <jbacik@fb.com>
>
> Acked-by: Daniel Borkmann <daniel@iogearbox.net>
>
> Thanks a lot for the test case! They are always useful to have ... which
> just reminds me: it seems we didn't add anything for f23cc643f9ba ("bpf:
> fix range arithmetic for bpf map access"). ;-)

I was hoping you wouldn't notice ;).  I'll add one in the next couple of days. 
Thanks,

Josef
