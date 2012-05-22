From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH] net: Surpress kmemleak messages on sysctl paths
Date: Tue, 22 May 2012 08:41:17 -0600
Message-ID: <878vgk1do2.fsf@xmission.com>
References: <1337647392.13348.14.camel@gandalf.stny.rr.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	LKML <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org,
	viro@zeniv.linux.org.uk, tixxdz@opendz.org
To: Steven Rostedt <rostedt@goodmis.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1337647392.13348.14.camel@gandalf.stny.rr.com> (Steven Rostedt's
	message of "Mon, 21 May 2012 20:43:12 -0400")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Steven Rostedt <rostedt@goodmis.org> writes:

> The network code allocates ctl_table_headers that are used for the life
> of the kernel. These headers are registered and never unregistered. The
> head pointer is allocated and not referenced, as it never needs to be
> unregistered, and the kmemleak detector triggers these as false
> positives:

The fix for this should already be merged into Linus's tree from the
net-next tree for 3.5.

Eric
