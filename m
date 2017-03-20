From: Shuah Khan <shuah@kernel.org>
Subject: Re: [PATCH v2 net] selftests/bpf: fix broken build, take 2
Date: Mon, 20 Mar 2017 10:37:26 -0600
Message-ID: <8300dcbc-8652-6366-bb57-96feb06c5998@kernel.org>
References: <1489989794-6859-1-git-send-email-zlim.lnx@gmail.com>
 <58CFF5D0.8040708@iogearbox.net>
 <20170320154523.GA80094@ast-mbp.thefacebook.com>
Reply-To: shuah@kernel.org
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: Zi Shen Lim <zlim.lnx@gmail.com>,
        Alexei Starovoitov <ast@kernel.org>, netdev@vger.kernel.org,
        Shuah Khan <shuah@kernel.org>
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from resqmta-po-11v.sys.comcast.net ([96.114.154.170]:55458 "EHLO
        resqmta-po-11v.sys.comcast.net" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1755872AbdCTQtW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 20 Mar 2017 12:49:22 -0400
In-Reply-To: <20170320154523.GA80094@ast-mbp.thefacebook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/20/2017 09:45 AM, Alexei Starovoitov wrote:
> On Mon, Mar 20, 2017 at 04:31:28PM +0100, Daniel Borkmann wrote:
>> On 03/20/2017 07:03 AM, Zi Shen Lim wrote:
>>> Merge of 'linux-kselftest-4.11-rc1':
>>>
>>> 1. Partially removed use of 'test_objs' target, breaking force rebuild of
>>> BPFOBJ, introduced in commit d498f8719a09 ("bpf: Rebuild bpf.o for any
>>> dependency update").
>>>
>>>   Update target so dependency on BPFOBJ is restored.
>>>
>>> 2. Introduced commit 2047f1d8ba28 ("selftests: Fix the .c linking rule")
>>> which fixes order of LDLIBS.
>>>
>>>   Commit d02d8986a768 ("bpf: Always test unprivileged programs") added
>>> libcap dependency into CFLAGS. Use LDLIBS instead to fix linking of
>>> test_verifier.
>>>
>>> 3. Introduced commit d83c3ba0b926 ("selftests: Fix selftests build to
>>> just build, not run tests").
>>>
>>>   Reordering the Makefile allows us to remove the 'all' target.
>>>
>>> Tested both:
>>>     selftests/bpf$ make
>>> and
>>>     selftests$ make TARGETS=bpf
>>> on Ubuntu 16.04.2.
>>>
>>> Signed-off-by: Zi Shen Lim <zlim.lnx@gmail.com>
>>
>> Looks reasonable to me as follow up to 1da8ac7c49fb ("selftests/bpf:
>> fix broken build"), thanks for fixing Zi!
>>
>> Acked-by: Daniel Borkmann <daniel@iogearbox.net>
>> Tested-by: Daniel Borkmann <daniel@iogearbox.net>
> 
> worked for me as well:
> Acked-by: Alexei Starovoitov <ast@kernel.org>
> Tested-by: Alexei Starovoitov <ast@kernel.org>
> 
> 
> 

David,

Could you please apply it to your tree. I think you already applied
the first fix.

Acked-by: Shuah Khan <shuahkh@osg.samsung.com>

thanks,
-- Shuah
