From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH net-next] net: filter: rename 'struct sock_filter_int'
 into 'struct bpf_insn'
Date: Thu, 24 Jul 2014 16:26:54 -0700
Message-ID: <CAMEtUuxHp5QzWQ+DhMPiNWDH6LxWPjgincK=Sk8xeJjivieY0w@mail.gmail.com>
References: <1406237179-3713-1-git-send-email-ast@plumgrid.com>
	<53D194F1.6020603@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
	Network Development <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <53D194F1.6020603@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jul 24, 2014 at 4:21 PM, Daniel Borkmann <dborkman@redhat.com> wrote:
> On 07/24/2014 11:26 PM, Alexei Starovoitov wrote:
>>
>> eBPF is used by socket filtering, seccomp and soon by tracing and
>> exposed to userspace, therefore 'sock_filter_int' name is not accurate.
>> Rename it to 'bpf_insn'
>>
>> Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>
>> ---
>
> ...
>
>>   #define BPF_ALU64_REG(OP, DST, SRC)                           \
>> -       ((struct sock_filter_int) {                             \
>> +       ((struct bpf_insn) {                            \
>
>
>                              ^^^ Please also fix up whitespacing here
>                                  and all the other sections below.

you mean to align last \ with other lines?
sure. good point.
