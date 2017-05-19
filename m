From: Alexei Starovoitov <ast@fb.com>
Subject: Re: [PATCH v2 1/3] bpf: Use 1<<16 as ceiling for immediate alignment
 in verifier.
Date: Fri, 19 May 2017 14:37:56 -0700
Message-ID: <a4a1fe92-fa35-1d3f-1b3c-e094d715db2c@fb.com>
References: <7402a02c-cb00-d48e-1d2a-ccb03356fb72@solarflare.com>
 <db8cd2e8-9f51-dc8b-5e55-4c75d13d4858@fb.com>
 <a0a47297-4765-3ba0-3ea2-013dda40e84a@solarflare.com>
 <20170519.164154.368589666756458942.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <daniel@iogearbox.net>, <alexei.starovoitov@gmail.com>,
        <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>, <ecree@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:41315 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751573AbdESViW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 19 May 2017 17:38:22 -0400
In-Reply-To: <20170519.164154.368589666756458942.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 5/19/17 1:41 PM, David Miller wrote:
> From: Edward Cree <ecree@solarflare.com>
> Date: Fri, 19 May 2017 18:17:42 +0100
>
>> One question: is there a way to build the verifier as userland code
>>  (or at least as a module), or will I have to reboot every time I
>>  want to test a change?
>
> There currently is no such machanism, you will have to reboot every
> time.
>
> I have considered working on making the code buildable outside of the
> kernel.  It shouldn't be too hard.

it's not hard.
We did it twice and both times abandoned.
First time to have 'user space verifier' to check programs before
loading and second time for fuzzing via llvm.
Abandoned since it diverges very quickly from kernel.
