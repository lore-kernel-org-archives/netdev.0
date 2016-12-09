From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCHv3 perf/core 0/7] Reuse libbpf from samples/bpf
Date: Fri, 09 Dec 2016 16:30:54 +0100
Message-ID: <584ACE2E.2090108@iogearbox.net>
References: <20161209024620.31660-1-joe@ovn.org> <20161209150907.GM8257@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
        wangnan0@huawei.com, ast@fb.com
To: Arnaldo Carvalho de Melo <acme@kernel.org>,
        Joe Stringer <joe@ovn.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:44802 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753889AbcLIPa7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 9 Dec 2016 10:30:59 -0500
In-Reply-To: <20161209150907.GM8257@kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Arnaldo,

On 12/09/2016 04:09 PM, Arnaldo Carvalho de Melo wrote:
> Em Thu, Dec 08, 2016 at 06:46:13PM -0800, Joe Stringer escreveu:
>> (Was "libbpf: Synchronize implementations")
>>
>> Update tools/lib/bpf to provide the remaining bpf wrapper pieces needed by the
>> samples/bpf/ code, then get rid of all of the duplicate BPF libraries in
>> samples/bpf/libbpf.[ch].
>>
>> ---
>> v3: Add ack for first patch.
>>      Split out second patch from v2 into separate changes for remaining diff.
>>      Add patches to switch samples/bpf over to using tools/lib/.
>> v2: https://www.mail-archive.com/netdev@vger.kernel.org/msg135088.html
>>      Don't shift non-bpf code into libbpf.
>>      Drop the patch to synchronize ELF definitions with tc.
>> v1: https://www.mail-archive.com/netdev@vger.kernel.org/msg135088.html
>>      First post.
>
> Thanks, applied after addressing the -I$(objtree) issue raised by Wang,

[ Sorry for late reply. ]

First of all, glad to see us getting rid of the duplicate lib eventually! :)

Please note that this might result in hopefully just a minor merge issue
with net-next. Looks like patch 4/7 touches test_maps.c and test_verifier.c,
which moved to a new bpf selftest suite [1] this net-next cycle. Seems it's
just log buffer and some renames there, which can be discarded for both
files sitting in selftests.

Thanks,
Daniel

   [1] https://git.kernel.org/cgit/linux/kernel/git/davem/net-next.git/tree/tools/testing/selftests/bpf
