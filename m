From: Jonathan Corbet <corbet@lwn.net>
Subject: Re: [PATCH v2 net-next 0/2] split BPF out of core networking
Date: Mon, 2 Jun 2014 08:15:45 -0500
Message-ID: <20140602081545.7baf4a91@lwn.net>
References: <1401692506-7796-1-git-send-email-ast@plumgrid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 8bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Ingo Molnar <mingo@kernel.org>,
	Steven Rostedt <rostedt@goodmis.org>,
	Daniel Borkmann <dborkman@redhat.com>,
	Chema Gonzalez <chema@google.com>,
	Eric Dumazet <edumazet@google.com>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Arnaldo Carvalho de Melo <acme@infradead.org>,
	Jiri Olsa <jolsa@redhat.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	"H. Peter Anvin" <hpa@zytor.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Kees Cook <keescook@chromium.org>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Alexei Starovoitov <ast@plumgrid.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1401692506-7796-1-git-send-email-ast@plumgrid.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon,  2 Jun 2014 00:01:44 -0700
Alexei Starovoitov <ast@plumgrid.com> wrote:

> This patch set splits BPF out of core networking into generic component

Quick, probably dumb question: if you're going to split it out, why not
split it out entirely, into kernel/ or (perhaps better) lib/?  The
whole point seems to be that BPF is outgrowing its networking home, so
it seems like it might be better to make it truly generic.

jon
