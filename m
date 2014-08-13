From: Andy Lutomirski <luto@amacapital.net>
Subject: Re: [PATCH RFC v4 net-next 01/26] net: filter: add "load 64-bit
 immediate" eBPF instruction
Date: Wed, 13 Aug 2014 14:38:49 -0700
Message-ID: <CALCETrUPLDs9mQmN-sC5K-2BppLpuXvjSqCETkxTGtkzC8diLg@mail.gmail.com>
References: <1407916658-8731-1-git-send-email-ast@plumgrid.com>
 <1407916658-8731-2-git-send-email-ast@plumgrid.com> <CALCETrXzZVxMGUgDPOKwN0DPLvupU=ew1z6D4U-jHg+RoyZyLg@mail.gmail.com>
 <CAMEtUuxog0w-XkYMHM=Zto_gejy8x5agxohAWOs1zPEtXTr0Sw@mail.gmail.com>
 <CALCETrXfp+7FmEzAoLiqzqY73NBzt8JsD40hzvhT3=gr-Scp=g@mail.gmail.com>
 <CAMEtUuwx6Y4qxyz4TGK9=M2BH-dXnPsm+JrusqbyjzK20yUv6A@mail.gmail.com>
 <CALCETrVDrbD3goYmZsUdmEhVfaNxovyghCz6y+_q5+G+rVwtWg@mail.gmail.com> <CAMEtUuyFF3Qvd8BHkbEqkjGx+UEC8KcowUYyyuBW2J_NcGA96Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
	Ingo Molnar <mingo@kernel.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Steven Rostedt <rostedt@goodmis.org>,
	Daniel Borkmann <dborkman@redhat.com>,
	Chema Gonzalez <chema@google.com>,
	Eric Dumazet <edumazet@google.com>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	"H. Peter Anvin" <hpa@zytor.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Kees Cook <keescook@chromium.org>,
	Linux API <linux-api@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Alexei Starovoitov <ast@plumgrid.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAMEtUuyFF3Qvd8BHkbEqkjGx+UEC8KcowUYyyuBW2J_NcGA96Q@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Aug 13, 2014 at 2:37 PM, Alexei Starovoitov <ast@plumgrid.com> wrote:
> I don't need an instruction that loads low 32-bit. It already exists.
> It's called 'mov'.
> I'm going to try encoding:
> insn[0].code = LD | IMM | DW
> insn[1].code = 0
> zero is invalid opcode, so it's your 'continuation'.
> and it is still single 16-byte instructions without any interpreter overhead.

Works for me.

--Andy
