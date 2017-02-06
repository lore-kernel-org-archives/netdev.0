From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net-next v1 6/7] bpf: Use the bpf_load_program() from
 the library
Date: Mon, 06 Feb 2017 23:44:09 +0100
Message-ID: <5898FC39.90701@iogearbox.net>
References: <20170205231428.23846-1-mic@digikod.net> <20170205231428.23846-6-mic@digikod.net> <58989691.7060403@iogearbox.net> <ed6c904f-2ea3-ff6f-3f4e-e0d9050f9a1e@digikod.net> <5898CBEF.20201@iogearbox.net> <1136c1a4-1a73-a419-5550-4ebd8aee9d25@digikod.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, Alexei Starovoitov <ast@fb.com>,
        Shuah Khan <shuah@kernel.org>
To: =?UTF-8?B?TWlja2HDq2wgU2FsYcO8bg==?= <mic@digikod.net>,
        linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1136c1a4-1a73-a419-5550-4ebd8aee9d25@digikod.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 02/06/2017 10:30 PM, Mickaël Salaün wrote:
> On 06/02/2017 20:18, Daniel Borkmann wrote:
>> On 02/06/2017 08:16 PM, Mickaël Salaün wrote:
>>> On 06/02/2017 16:30, Daniel Borkmann wrote:
>>>> On 02/06/2017 12:14 AM, Mickaël Salaün wrote:
>>>>> Replace bpf_prog_load() with bpf_load_program() calls.
>>>>>
>>>>> Use the tools include directory instead of the installed one to allow
>>>>> builds from other kernels.
>>>>>
>>>>> Signed-off-by: Mickaël Salaün <mic@digikod.net>
>>>>> Cc: Alexei Starovoitov <ast@fb.com>
>>>>> Cc: Daniel Borkmann <daniel@iogearbox.net>
>>>>> Cc: Shuah Khan <shuah@kernel.org>
>>>>> ---
>>>>>     tools/testing/selftests/bpf/Makefile        |  6 +++++-
>>>>>     tools/testing/selftests/bpf/bpf_sys.h       | 21
>>>>> ---------------------
>>>>>     tools/testing/selftests/bpf/test_tag.c      |  6 ++++--
>>>>>     tools/testing/selftests/bpf/test_verifier.c |  8 +++++---
>>>>>     4 files changed, 14 insertions(+), 27 deletions(-)
>>>>
>>>> No objections, but if so, can't we add the remaining missing
>>>> pieces to bpf lib, so we can remove bpf_sys.h altogether?
>>>
>>> OK, I'll send a new patch replacing bpf_sys.h entirely.
>>
>> Sounds great, thanks!
>
> Do you prefer a big patch or one for each replaced function?

I think it makes sense to split it into two: i) this patch as-is
for the prog part, and ii) rest for maps.
