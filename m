From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [PATCH v8 net-next 1/3] filter: add Extended BPF interpreter and converter
Date: Mon, 10 Mar 2014 19:05:28 -0700
Message-ID: <CA+55aFwB5Z74+zi5-9O9jPLxZDZDJjioaJa6MSWQjhVEn_hn4Q@mail.gmail.com>
References: <1394431444-6987-1-git-send-email-ast@plumgrid.com>
	<1394431444-6987-2-git-send-email-ast@plumgrid.com>
	<20140310.215104.2095195123238829635.davem@davemloft.net>
	<CA+55aFx7rdm9DGOTTgAKTHNkdfrvQYhT9PRs5MhUPr1gQzWEgA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: ast@plumgrid.com, dborkman@redhat.com,
	Ingo Molnar <mingo@kernel.org>, Will Drewry <wad@chromium.org>,
	Steven Rostedt <rostedt@goodmis.org>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Peter Anvin <hpa@zytor.com>,
	Hagen Paul Pfeifer <hagen@jauu.net>,
	Jesse Gross <jesse@nicira.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	Eric Dumazet <edumazet@google.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	=?UTF-8?B?RnLDqWTDqXJpYyBXZWlzYmVja2Vy?= <fweisbec@gmail.com>,
	Arnaldo Carvalho de Melo <acme@infradead.org>,
	penberg@iki.fi, Arjan van de Ven <arjan@infradead.org>,
	Christoph Hellwig <hch@infradead.org>,
	Pavel Emelyanov <xemul@parallels.com>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CA+55aFx7rdm9DGOTTgAKTHNkdfrvQYhT9PRs5MhUPr1gQzWEgA@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Mar 10, 2014 at 7:02 PM, Linus Torvalds
<torvalds@linux-foundation.org> wrote:
>
> So please don't sell "bool" as some kind of panacea. It has at least
> as many problems as it has advantages.

Side note: not that bitfields are all that great either, partly
because gcc tends to occasionally generate absolutely disgusting code
for even simple things, and they have the worse-than-average problems
with byte/bit ordering etc. So quite frankly, often "unsigned int
flags" together with manual accesses is the way to go if you care
about code generation quality. Of course, there's the whole
convenience issue..

          Linus
