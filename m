From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH v11 net-next 00/12] eBPF syscall, verifier, testsuite
Date: Wed, 10 Sep 2014 10:48:24 -0700
Message-ID: <CAMEtUuxXNX9fhZ2Nm+Y=Y__AfdeDBRf86Hq7=4Od=L5=JzDubQ@mail.gmail.com>
References: <1410325808-3657-1-git-send-email-ast@plumgrid.com>
	<541017FD.1030308@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
	Ingo Molnar <mingo@kernel.org>,
	Linus Torvalds <torvalds@linuxfoundation.org>,
	Andy Lutomirski <luto@amacapital.net>,
	Steven Rostedt <rostedt@goodmis.org>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Chema Gonzalez <chema@google.com>,
	Eric Dumazet <edumazet@google.com>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	"H. Peter Anvin" <hpa@zytor.com>,
	Andrew Morton <akpm@linuxfoundation.org>,
	Kees Cook <keescook@chromium.org>,
	Linux API <linux-api@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <541017FD.1030308@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Sep 10, 2014 at 2:21 AM, Daniel Borkmann <dborkman@redhat.com> wrote:
>
> When you pass in these structs with pointers in it to other user space
> buffers, how do you handle this with mixed 32/64 bit user/kernel space?
...
> Perhaps I'm missing something, but I think, that would currently break in
> your syscall handler, no?

yes. compat stuff is not part of this diff.
I was thinking to handle it similar to the way signalfd deals with it:
add compat syscall, compat struct and convert it before going into
main entry point.
