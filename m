From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v8 net-next 1/3] filter: add Extended BPF interpreter
 and converter
Date: Mon, 10 Mar 2014 21:51:04 -0400 (EDT)
Message-ID: <20140310.215104.2095195123238829635.davem@davemloft.net>
References: <1394431444-6987-1-git-send-email-ast@plumgrid.com>
	<1394431444-6987-2-git-send-email-ast@plumgrid.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dborkman@redhat.com, mingo@kernel.org, wad@chromium.org,
	rostedt@goodmis.org, a.p.zijlstra@chello.nl, hpa@zytor.com,
	hagen@jauu.net, jesse@nicira.com, tglx@linutronix.de,
	edumazet@google.com, torvalds@linux-foundation.org,
	akpm@linux-foundation.org, fweisbec@gmail.com, acme@infradead.org,
	penberg@iki.fi, arjan@infradead.org, hch@infradead.org,
	xemul@parallels.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: ast@plumgrid.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1394431444-6987-2-git-send-email-ast@plumgrid.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Alexei Starovoitov <ast@plumgrid.com>
Date: Sun,  9 Mar 2014 23:04:02 -0700

> +	unsigned int		jited:1;

The C language has a proper type for boolean states, please therefore
use 'bool', true, and false.
