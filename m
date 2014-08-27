From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH RFC v7 net-next 00/28] BPF syscall
Date: Tue, 26 Aug 2014 21:35:26 -0700
Message-ID: <CAMEtUuwYqJVUuZxPBKy57NonWF+X_5vkNx4uSEx_d=-xBka1Kg@mail.gmail.com>
References: <1409106582-10095-1-git-send-email-ast@plumgrid.com>
	<CALCETrX2MzNxQ1ogt+Qx8iPjUe+z0gN6ZLwu9nAcZzTN+D+iYw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Daniel Borkmann <dborkman@redhat.com>,
	"H. Peter Anvin" <hpa@zytor.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Chema Gonzalez <chema@google.com>,
	Namhyung Kim <namhyung@kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	"David S. Miller" <davem@davemloft.net>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Brendan Gregg <brendan.d.gregg@gmail.com>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Steven Rostedt <rostedt@goodmis.org>,
	Network Development <netdev@vger.kernel.org>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Kees Cook <keescook@chromium.org>,
	Linux API <linux-api@vger.kernel.org>,
	Ingo Molnar <mingo@kernel.org>
To: Andy Lutomirski <luto@amacapital.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CALCETrX2MzNxQ1ogt+Qx8iPjUe+z0gN6ZLwu9nAcZzTN+D+iYw@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Aug 26, 2014 at 8:56 PM, Andy Lutomirski <luto@amacapital.net> wrote:
> On Aug 26, 2014 7:29 PM, "Alexei Starovoitov" <ast@plumgrid.com> wrote:
>>
>> Hi Ingo, David,
>>
>> posting whole thing again as RFC to get feedback on syscall only.
>> If syscall bpf(int cmd, union bpf_attr *attr, unsigned int size) is ok,
>> I'll split them into small chunks as requested and will repost without RFC.
>
> IMO it's much easier to review a syscall if we just look at a
> specification of what it does.  The code is, in some sense, secondary.

'specification of what it does'... hmm, you mean beyond what's
there in commit logs and in Documentation/networking/filter.txt ?
Aren't samples at the end give an idea on 'what it does'?
I'm happy to add 'specification', I just don't understand yet what
it suppose to talk about beyond what's already written.
I understand that the patches are missing explanation on 'why'
the syscall is being added, but I don't think it's what you're asking...
