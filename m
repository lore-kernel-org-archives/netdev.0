From: Joe Stringer <joe@ovn.org>
Subject: Re: [PATCHv2 perf/core 0/7] Libbpf improvements
Date: Tue, 24 Jan 2017 16:50:57 -0800
Message-ID: <CAPWQB7GYmN6oyK3_BbJTGffhCZmDK3MHmRNymgunF_kbMUu-=Q@mail.gmail.com>
References: <20170123011128.26534-1-joe@ovn.org> <20170124161210.GE10340@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Wang Nan <wangnan0@huawei.com>, ast@fb.com,
        Daniel Borkmann <daniel@iogearbox.net>,
        LKML <linux-kernel@vger.kernel.org>,
        netdev <netdev@vger.kernel.org>
To: Arnaldo Carvalho de Melo <acme@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170124161210.GE10340@kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 24 January 2017 at 08:12, Arnaldo Carvalho de Melo <acme@kernel.org> wrote:
> Em Sun, Jan 22, 2017 at 05:11:21PM -0800, Joe Stringer escreveu:
>> Patch 1 fixes an issue when using drastically different BPF map definitions
>> inside ELFs from a client using libbpf, vs the map definition libbpf uses.
>>
>> Patches 2-4 add some simple, useful helper functions for setting prog type
>> and retrieving libbpf errors without depending on kernel headers from
>> userspace programs.
>>
>> Patches 5-7 add a new pinning functionality for maps, programs, and objects.
>> Library users may call bpf_map__pin(map, path) or bpf_program__pin(prog, path)
>> to pin maps and programs separately, or use bpf_object__pin(obj, path) to
>> pin all maps and programs from the BPF object to the path. The map and program
>> variations require a full path where it will be pinned in the filesystem,
>> and the object variation will create directories "maps/" and "progs/" under
>> the specified path, then mount each map and program under those subdirectories.
>
> Merged the ones either acked by Wang or adjusted by you to address
> Wang's remarks, the last ones introducing those __pin() methods, please
> provide users together with those APIs, preferably entries for 'perf
> test',

OK great, I'll rebase the last 3 patches and add a test to perf test
for pinning.
