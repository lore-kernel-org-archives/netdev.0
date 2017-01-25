From: "Wangnan (F)" <wangnan0@huawei.com>
Subject: Re: [PATCHv2 perf/core 5/7] tools lib bpf: Add bpf_program__pin()
Date: Wed, 25 Jan 2017 09:06:19 +0800
Message-ID: <921d83a9-aa44-acee-4fcf-dbc45cc0a66a@huawei.com>
References: <20170123011128.26534-1-joe@ovn.org>
 <20170123011128.26534-6-joe@ovn.org>
 <e24b0753-43ee-fad5-86c4-a3699caff05d@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <ast@fb.com>, <daniel@iogearbox.net>,
        <linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>
To: Joe Stringer <joe@ovn.org>, <acme@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <e24b0753-43ee-fad5-86c4-a3699caff05d@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On 2017/1/25 9:04, Wangnan (F) wrote:
>
>
> On 2017/1/23 9:11, Joe Stringer wrote:
>> Add a new API to pin a BPF program to the filesystem. The user can
>> specify the path full path within a BPF filesystem to pin the program.
>> Programs with multiple instances are pinned as 'foo', 'foo_1', 'foo_2',
>> and so on.
>>
>> Signed-off-by: Joe Stringer <joe@ovn.org>
>> ---
>> v2: Don't automount BPF filesystem
>>      Split program, map, object pinning into separate APIs and separate
>>      patches.
>> ---

[SNIP]

>> +int bpf_program__pin(struct bpf_program *prog, const char *path)
>
> In your next patch please let caller select one instance:
>
> int bpf_program__pin(struct bpf_program *prog, int instance, const 
> char *path)
> (please choose a better name)
>
> Then your can wrap it with another function to pin all instances, 
> implement
> naming schema (%s_%d) there.
>
> Then implement naming schema in bpf_object__pin like:
>
> %s/objectname_mapname
> %s/objectname_progname_%d
>

Is it possible to use directory tree instead?

%s/object/mapname
%s/object/prog/instance

Thank you.
