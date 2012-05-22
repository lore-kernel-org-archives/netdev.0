From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [PATCH] net: Surpress kmemleak messages on sysctl paths
Date: Tue, 22 May 2012 10:51:20 -0400
Message-ID: <1337698280.13348.47.camel@gandalf.stny.rr.com>
References: <1337647392.13348.14.camel@gandalf.stny.rr.com>
	 <878vgk1do2.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-15"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	LKML <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org,
	viro@zeniv.linux.org.uk, tixxdz@opendz.org
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <878vgk1do2.fsf@xmission.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2012-05-22 at 08:41 -0600, Eric W. Biederman wrote:
> Steven Rostedt <rostedt@goodmis.org> writes:
> 
> > The network code allocates ctl_table_headers that are used for the life
> > of the kernel. These headers are registered and never unregistered. The
> > head pointer is allocated and not referenced, as it never needs to be
> > unregistered, and the kmemleak detector triggers these as false
> > positives:
> 
> The fix for this should already be merged into Linus's tree from the
> net-next tree for 3.5.

Ah, I didn't look at net-next. I just looked at 3.4 and didn't see
anything. If that's the case, simply ignore :-)

-- Steve
