From: Joe Stringer <joe@ovn.org>
Subject: Re: [PATCHv2 perf/core 2/2] tools lib bpf: Sync with samples/bpf/libbpf
Date: Wed, 16 Nov 2016 19:53:24 -0800
Message-ID: <CAPWQB7HTHWKNnn+WyEbaewhEg-HoPDLzYs7dWPR90jjZ=UNVuQ@mail.gmail.com>
References: <20161116174324.29675-1-joe@ovn.org> <20161116174324.29675-3-joe@ovn.org>
 <582D11B0.80208@huawei.com> <CAOftzPhXk0LKCt8wQKuqeBnDrj6a4p0YL7P80jhK78eFSAz8WQ@mail.gmail.com>
 <582D265B.4000102@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: LKML <linux-kernel@vger.kernel.org>,
        netdev <netdev@vger.kernel.org>, ast@fb.com,
        Daniel Borkmann <daniel@iogearbox.net>,
        Arnaldo Carvalho de Melo <acme@kernel.org>
To: "Wangnan (F)" <wangnan0@huawei.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <582D265B.4000102@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 16 November 2016 at 19:39, Wangnan (F) <wangnan0@huawei.com> wrote:
>
>
> On 2016/11/17 10:46, Joe Stringer wrote:
>>
>> On 16 November 2016 at 18:10, Wangnan (F) <wangnan0@huawei.com> wrote:
>>>
>>> I'm also working on improving bpf.c. Please have a look at:
>>>
>>> https://lkml.org/lkml/2016/11/14/1078
>>>
>>> Since bpf.c is simple, I think we can add more functions and fixes
>>> gradually, instead of a full copy.
>>>
>>> See my inline comment below.
>>
>> Ah, I missed this, my apologies. It looks like it will provide much of
>> what I need, I can reassess this patch with your series in mind.
>>
>> One comment though for your patch (I don't have the original thread to
>> respond to unfortunately): The map_pin and map_get functions in your
>> patch series can be used to pin progs too, so maybe there is a better
>> name? You'll see that this patch uses bpf_obj_{pin,get}() - although I
>> wouldn't want those to be confused with the libbpf.c objects so maybe
>> there's a clearer name that could be used.
>>
>> I also have some patches to rework the samples/bpf/* code to use
>> libbpf instead of the sample code that is there, is it worth me
>> submitting that? It will need to wait for your patch to go in, plus a
>> merge with davem's tree.
>>
> I'm happy to see you are trying to replace samples/bpf 's own
> libbpf with tools/lib/bpf. I think you can submit your work
> on libbpf and patches on samples together if they are ready.
> Arnaldo can pick up patches good for him, and you can improve
> other patches based on his newest branch.

I'll look into it.
