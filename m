From: "David S. Miller" <davem@redhat.com>
Subject: Re: kernel bug in socketpair()
Date: Wed, 23 Jul 2003 07:04:31 -0700
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <20030723070431.13859c09.davem@redhat.com>
References: <200307231332.JAA26197@raptor.research.att.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, gsf@research.att.com,
	netdev@oss.sgi.com
Return-path: <linux-kernel-owner+linux-kernel=40quimby.gnus.org@vger.kernel.org>
To: David Korn <dgk@research.att.com>
In-Reply-To: <200307231332.JAA26197@raptor.research.att.com>
List-Id: netdev.vger.kernel.org

On Wed, 23 Jul 2003 09:32:09 -0400 (EDT)
David Korn <dgk@research.att.com> wrote:

[ Added netdev@oss.sgi.com, the proper place to discuss networking kernel issues. ]

> The first problem is that files created with socketpair() are not accessible
> via /dev/fd/n or /proc/$$/fd/n where n is the file descriptor returned
> by socketpair().  Note that this is not a problem with pipe().

Not a bug.

Sockets are not openable via /proc files under any circumstances,
not just the circumstances you describe.  This is a policy decision and
prevents a whole slew of potential security holes.
