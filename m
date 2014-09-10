From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH v11 net-next 00/12] eBPF syscall, verifier, testsuite
Date: Wed, 10 Sep 2014 11:03:10 +0200
Message-ID: <541013CE.6020307@redhat.com>
References: <1410325808-3657-1-git-send-email-ast@plumgrid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
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
	Kees Cook <keescook@chromium.org>, linux-api@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Alexei Starovoitov <ast@plumgrid.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1410325808-3657-1-git-send-email-ast@plumgrid.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 09/10/2014 07:09 AM, Alexei Starovoitov wrote:
...
>             struct { /* anonymous struct used by BPF_MAP_*_ELEM commands */
>                 int map_fd;
>                 void *key;
>                 union {
>                     void *value;
>                     void *next_key;
>                 };
>             };
>
>             struct { /* anonymous struct used by BPF_PROG_LOAD command */
>                 enum bpf_prog_type    prog_type;
>                 __u32                 insn_cnt;
>                 const struct bpf_insn *insns;
>                 const char            *license;
>                 __u32                 log_level; /* verbosity level of eBPF verifier */
>                 __u32                 log_size;  /* size of user buffer */
>                 void                  *log_buf;  /* user supplied buffer */

What is log buffer? Would that mean the verifier will return an error
string if the program will not pass it, or if not, what other data?
I think the man page is missing how to examine the returned verifier
log buffer data.
