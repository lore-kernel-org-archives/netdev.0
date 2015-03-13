From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH net-next 1/2] bpf: allow extended BPF programs access
 skb fields
Date: Fri, 13 Mar 2015 10:09:21 -0700
Message-ID: <550319C1.50209@plumgrid.com>
References: <1426213271-8363-1-git-send-email-ast@plumgrid.com> <1426213271-8363-2-git-send-email-ast@plumgrid.com> <5502B48B.7040909@iogearbox.net> <55030ED8.4020209@plumgrid.com> <550313B6.2080701@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Thomas Graf <tgraf@suug.ch>, linux-api@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Daniel Borkmann <daniel@iogearbox.net>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <550313B6.2080701@iogearbox.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 3/13/15 9:43 AM, Daniel Borkmann wrote:
> On 03/13/2015 05:22 PM, Alexei Starovoitov wrote:
>> On 3/13/15 2:57 AM, Daniel Borkmann wrote:
>>> On 03/13/2015 03:21 AM, Alexei Starovoitov wrote:
>>>> introduce user accessible mirror of in-kernel 'struct sk_buff':
>>>
>>> For each member, I'd also add BUILD_BUG_ON()s similarly as we have in
>>> convert_bpf_extensions(). That way, people won't forget to adjust the
>>> code.
>>
>> I thought about it, but didn't add it, since we already have them
>> in the same file several lines above this spot.
>> I think one build error per .c file should be enough to attract
>> attention.
>> Though I'll add a comment to convert_bpf_extensions() that build_bug_on
>> errors should be addressed in two places.
>
> My concern would be that in case the code gets changed, this spot
> could easily be overlooked by someone possibly unfamiliar with the
> code, since no build error triggers there.
>
> So I guess it wouldn't hurt or cost us much to also adding the
> BUILD_BUG_ON()s there instead of a comment.

I think it's overkill, but fine, it's minor. Will add another set
of build_bug_ons and see how it looks.
