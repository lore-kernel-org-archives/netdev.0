From: Alexei Starovoitov <ast@fb.com>
Subject: Re: llvm-objdump...
Date: Fri, 28 Apr 2017 09:22:32 -0700
Message-ID: <c9e9eaa7-0fa8-440a-dc75-2d4020b8c429@fb.com>
References: <20170425.131337.2175176102097155053.davem@davemloft.net>
 <612f0df6-711c-b6b1-4bd7-596a7f329737@fb.com>
 <20170428.121710.1780087759147659481.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <daniel@iogearbox.net>, <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:41805 "EHLO
        mx0b-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1756176AbdD1QWx (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 28 Apr 2017 12:22:53 -0400
In-Reply-To: <20170428.121710.1780087759147659481.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 4/28/17 9:17 AM, David Miller wrote:
> Even if I give it -triple=bpfeb it emits immediates incorrectly.
>
> The bug is certainly in the insn field fetcher of the disassembler.

got it. so the binary looks correct, but disasm output is wrong?
Thanks! Looks like there is a bug there indeed.
