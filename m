From: xiakaixu <xiakaixu@huawei.com>
Subject: Re: [PATCH V4 1/1] bpf: control events stored in PERF_EVENT_ARRAY
 maps trace data output when perf sampling
Date: Tue, 20 Oct 2015 10:35:25 +0800
Message-ID: <5625A86D.6050102@huawei.com>
References: <1445251060-114617-1-git-send-email-xiakaixu@huawei.com> <1445251060-114617-2-git-send-email-xiakaixu@huawei.com> <5625A36D.8070200@plumgrid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <davem@davemloft.net>, <acme@kernel.org>, <mingo@redhat.com>,
	<a.p.zijlstra@chello.nl>, <masami.hiramatsu.pt@hitachi.com>,
	<jolsa@kernel.org>, <daniel@iogearbox.net>, <wangnan0@huawei.com>,
	<linux-kernel@vger.kernel.org>, <pi3orama@163.com>,
	<hekuang@huawei.com>, <netdev@vger.kernel.org>
To: Alexei Starovoitov <ast@plumgrid.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <5625A36D.8070200@plumgrid.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=E4=BA=8E 2015/10/20 10:14, Alexei Starovoitov =E5=86=99=E9=81=93:
> On 10/19/15 3:37 AM, Kaixu Xia wrote:
>> +/* flags for PERF_EVENT_ARRAY maps*/
>> +enum {
>> +    BPF_EVENT_CTL_BIT_CUR =3D 0,
>> +    BPF_EVENT_CTL_BIT_ALL =3D 1,
>> +    __NR_BPF_EVENT_CTL_BITS,
>> +};
>> +
>> +#define    BPF_CTL_BIT_FLAG_MASK \
>> +    ((1ULL << __NR_BPF_EVENT_CTL_BITS) - 1)
>> +#define    BPF_CTL_BIT_DUMP_CUR \
>> +    (1ULL << BPF_EVENT_CTL_BIT_CUR)
>> +#define    BPF_CTL_BIT_DUMP_ALL \
>> +    (1ULL << BPF_EVENT_CTL_BIT_ALL)
>> +
>=20
> the above shouldn't be part of uapi header. It can stay in bpf_trace.=
c
> Just document these bits next to helper similar to skb_store_bytes()
>=20
> The rest looks ok.
> It still needs an ack from Peter for perf_event bits

Thanks for your comments!
This part will be moved to bpf_trace.c in next version.
>=20
>=20
> .
>=20
