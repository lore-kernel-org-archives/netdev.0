From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] compat bug in sys_recvmsg, MSG_CMSG_COMPAT check
 missing
Date: Sat, 5 Jun 2004 14:36:49 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040605143649.3fd6c22b.davem@redhat.com>
References: <20040605204334.GA1134@suse.de>
	<20040605140153.6c5945a0.davem@redhat.com>
	<20040605140544.0de4034d.davem@redhat.com>
	<jer7st7lam.fsf@sykes.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: olh@suse.de, linux-kernel@vger.kernel.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Andreas Schwab <schwab@suse.de>
In-Reply-To: <jer7st7lam.fsf@sykes.suse.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, 05 Jun 2004 23:21:53 +0200
Andreas Schwab <schwab@suse.de> wrote:

> "David S. Miller" <davem@redhat.com> writes:
> 
> > This means also that Olaf's patch is broken, when CONFIG_COMPAT is not
> > set, MSG_CMSG_COMPAT is zero, thus ~MSG_CMSG_COMPAT is the unexpected
> > value all 1's thus breaking the tests for unexpected flags completely.
> 
> ??? Where do you get ~MSG_CMSG_COMPAT from?

Olaf's patch, it said:

-	if (flags & ~(MSG_PEEK|MSG_DONTWAIT|MSG_TRUNC))
+	if (flags & ~(MSG_PEEK|MSG_DONTWAIT|MSG_TRUNC|MSG_CMSG_COMPAT))
