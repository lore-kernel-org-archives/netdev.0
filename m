From: David Ahern <dsahern@gmail.com>
Subject: Re: [PATCH v1] samples/bpf: Add a .gitignore for binaries
Date: Thu, 18 May 2017 13:03:31 -0700
Message-ID: <1ce3f092-3552-173f-b26a-48ec81d49f55@gmail.com>
References: <20170212212356.11675-1-mic@digikod.net>
 <8277c7cc-8f44-40ec-1f7e-53c404d84292@cumulusnetworks.com>
 <bd91cc8d-4683-4c4c-e672-7dce5da28183@digikod.net>
 <ad02fd5c-6812-8f1b-b348-b2ec81b9524b@gmail.com>
 <20170517081844.GA4447@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: =?UTF-8?Q?Micka=c3=abl_Sala=c3=bcn?= <mic@digikod.net>,
        Alexei Starovoitov <ast@fb.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        linux-kernel@vger.kernel.org,
        Arnaldo Carvalho de Melo <acme@redhat.com>,
        Wang Nan <wangnan0@huawei.com>, netdev@vger.kernel.org
To: Alexander Alemayhu <alexander@alemayhu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:33759 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753200AbdERUDe (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 18 May 2017 16:03:34 -0400
In-Reply-To: <20170517081844.GA4447@gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 5/17/17 1:18 AM, Alexander Alemayhu wrote:
> I have looked into this but found it to be not easy and all attempts to
> change the Makefile has resulted in obscure errors :/
> 
> Getting clang to output in a different directory was easy[0], but I guess
> this is not the right approach either. Have you tried making the change?

spent an hour so a few weeks back. It is not trivial, but someone needs
to find to fix it now.

perf is the example to use: you can build it from both top level kernel
directory (e.g, make -C tools/perf O=/tmp/perf) and the perf directory
(cd tools/perf; make O=/tmp/perf). Both are wanted for samples/bpf and
it would be nice to keep the O= option as well.

I don't have the time for the next few weeks. Perhaps mid-June I can
take a look.
