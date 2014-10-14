From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH v9 net-next 2/4] net: filter: split filter.h and expose
 eBPF to user space
Date: Tue, 14 Oct 2014 09:34:30 +0200
Message-ID: <543CD206.709@redhat.com>
References: <1409714246-31054-1-git-send-email-ast@plumgrid.com> <1409714246-31054-3-git-send-email-ast@plumgrid.com> <540737DF.1010801@redhat.com> <543C0A2D.5040908@redhat.com> <CAMEtUuw-iAGiYqmcN0AOkku0+Wto7810JJo9HEQvQN-2F=baTA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Ingo Molnar <mingo@kernel.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Andy Lutomirski <luto@amacapital.net>,
	Steven Rostedt <rostedt@goodmis.org>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Chema Gonzalez <chema@google.com>,
	Eric Dumazet <edumazet@google.com>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	"H. Peter Anvin" <hpa@zytor.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Kees Cook <keescook@chromium.org>,
	Linux API <linux-api@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Alexei Starovoitov <ast@plumgrid.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAMEtUuw-iAGiYqmcN0AOkku0+Wto7810JJo9HEQvQN-2F=baTA@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/13/2014 11:49 PM, Alexei Starovoitov wrote:
> On Mon, Oct 13, 2014 at 10:21 AM, Daniel Borkmann <dborkman@redhat.com> wrote:
>> On 09/03/2014 05:46 PM, Daniel Borkmann wrote:
>> ...
>>>
>>> Ok, given you post the remaining two RFCs later on this window as
>>> you indicate, I have no objections:
>>>
>>> Acked-by: Daniel Borkmann <dborkman@redhat.com>
>>
>> Ping, Alexei, are you still sending the patch for bpf_common.h or
>> do you want me to take care of this?
>
> It's not forgotten.
> I'm not sending it only because net-next is closed
> and it seems to be -next material.

Well, the point was since it's UAPI you're modifying, that it needs
to be shipped before it first gets exposed to user land ...

I think that should be reason enough ... there's no point in doing
this at a later point in time.
