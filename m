From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] compat bug in sys_recvmsg, MSG_CMSG_COMPAT check
 missing
Date: Sat, 5 Jun 2004 14:05:44 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040605140544.0de4034d.davem@redhat.com>
References: <20040605204334.GA1134@suse.de>
	<20040605140153.6c5945a0.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: olh@suse.de, linux-kernel@vger.kernel.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20040605140153.6c5945a0.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


[ Replying to myself :-) ]

On Sat, 5 Jun 2004 14:01:53 -0700
"David S. Miller" <davem@redhat.com> wrote:

> Let's ask a better question, why do we need to pass this thing down
> into the implementations anyways?

It's for net/core/scm.c handling, sigh.

This means also that Olaf's patch is broken, when CONFIG_COMPAT is not
set, MSG_CMSG_COMPAT is zero, thus ~MSG_CMSG_COMPAT is the unexpected
value all 1's thus breaking the tests for unexpected flags completely.

Any better ideas?
