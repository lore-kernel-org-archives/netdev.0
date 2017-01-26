From: Joe Stringer <joe@ovn.org>
Subject: Re: [PATCHv2 perf/core 5/7] tools lib bpf: Add bpf_program__pin()
Date: Thu, 26 Jan 2017 11:43:52 -0800
Message-ID: <CAPWQB7E65hJPO9JPAtN-HxM3VUue2yrmx++YkQDTFL6oExVKpA@mail.gmail.com>
References: <20170123011128.26534-1-joe@ovn.org> <20170123011128.26534-6-joe@ovn.org>
 <e24b0753-43ee-fad5-86c4-a3699caff05d@huawei.com> <921d83a9-aa44-acee-4fcf-dbc45cc0a66a@huawei.com>
 <CAPWQB7EWFE6DToMwTws6rUpnO49UYV1Rq-=0KV2ZioUf+dTjpg@mail.gmail.com>
 <b93c8045-7408-fb8d-f8a1-c0d11bdbc791@huawei.com> <20170126193240.GC17504@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: ast@fb.com, "Wangnan (F)" <wangnan0@huawei.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        LKML <linux-kernel@vger.kernel.org>,
        netdev <netdev@vger.kernel.org>
To: Arnaldo Carvalho de Melo <acme@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170126193240.GC17504@kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 26 January 2017 at 11:32, Arnaldo Carvalho de Melo <acme@kernel.org> wrote:
> Em Wed, Jan 25, 2017 at 10:18:22AM +0800, Wangnan (F) escreveu:
>> On 2017/1/25 9:16, Joe Stringer wrote:
>> > On 24 January 2017 at 17:06, Wangnan (F) <wangnan0@huawei.com> wrote:
>> > > On 2017/1/25 9:04, Wangnan (F) wrote:
>> > > Is it possible to use directory tree instead?
>
>> > > %s/object/mapname
>> > > %s/object/prog/instance
>> > I don't think objects have names, so let's assume an object with two
>> > program instances named foo, and one map named bar.
>
>> > A call of bpf_object__pin(obj, "/sys/fs/bpf/myobj") would mount with
>> > the following files and directories:
>> > /sys/fs/bpf/myobj/foo/1
>> > /sys/fs/bpf/myobj/foo/2
>> > /sys/fs/bpf/myobj/bar
>
>> > Alternatively, if you want to control exactly where you want the
>> > progs/maps to be pinned, you can call eg
>> > bpf_program__pin_instance(prog, "/sys/fs/bpf/wherever", 0) and that
>> > instance will be mounted to /sys/fs/bpf/wherever, or alternatively
>> > bpf_program__pin(prog, "/sys/fs/bpf/foo"), and you will end up with
>> > /sys/fs/bpf/foo/{0,1}.
>
>> > This looks pretty reasonable to me.
>
>> It looks good to me.
>
> Ok, please continue from perf/core, Ingo merged the first patch of this
> patchset today,

Ok thanks, I'll continue from there.
