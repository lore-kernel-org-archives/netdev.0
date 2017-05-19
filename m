From: Edward Cree <ecree@solarflare.com>
Subject: Re: [PATCH v2 1/3] bpf: Use 1<<16 as ceiling for immediate alignment
 in verifier.
Date: Fri, 19 May 2017 18:17:42 +0100
Message-ID: <a0a47297-4765-3ba0-3ea2-013dda40e84a@solarflare.com>
References: <20170515.120431.1588221938554447723.davem@davemloft.net>
 <754f2c39-fdb0-2407-c2f2-aa36d506d202@solarflare.com>
 <f2bff26d-8b4d-c6a2-23c9-9db198569e40@fb.com>
 <50288778-10f6-7201-c979-bfe4635831fc@solarflare.com>
 <e873f261-e1c1-c344-3d72-254623e0c91a@solarflare.com>
 <97910214-213c-c5c6-4a02-adc16cd836aa@fb.com>
 <c8e4ce49-5707-3d6d-c8c2-80dd8335d981@solarflare.com>
 <739ef342-728c-de57-c2a2-03fa85b3a246@solarflare.com>
 <17a1c4a2-68d7-0f8f-f009-b97706d67ceb@fb.com>
 <7402a02c-cb00-d48e-1d2a-ccb03356fb72@solarflare.com>
 <db8cd2e8-9f51-dc8b-5e55-4c75d13d4858@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <alexei.starovoitov@gmail.com>, <netdev@vger.kernel.org>
To: Alexei Starovoitov <ast@fb.com>,
        David Miller <davem@davemloft.net>,
        Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dispatch1-us1.ppe-hosted.com ([67.231.154.164]:36150 "EHLO
        dispatch1-us1.ppe-hosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1750734AbdESRR4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 19 May 2017 13:17:56 -0400
In-Reply-To: <db8cd2e8-9f51-dc8b-5e55-4c75d13d4858@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 19/05/17 15:55, Alexei Starovoitov wrote:
> On 5/19/17 7:21 AM, Edward Cree wrote:
>> I'm currently translating the algos to C.  But for the kernel patch,
>>  I'll need to read & understand the existing verifier code, so it
>>  might take a while :)  (I don't suppose there's any design document
>>  or hacking-notes you could point me at?)
>
> Dave just gave a good overview of the verifier:
> https://www.spinics.net/lists/xdp-newbies/msg00185.html
>
> Few more details in
> Documentation/networking/filter.txt
> and in top comments in kernel/bpf/verifier.c
>
> General bpf arch overview:
> http://docs.cilium.io/en/latest/bpf/#instruction-set 
Thanks for the links!  I'm digging into implementation now.
One question: is there a way to build the verifier as userland code
 (or at least as a module), or will I have to reboot every time I
 want to test a change?
-Ed
