From: "David S. Miller" <davem@redhat.com>
Subject: Re: kernel bug in socketpair()
Date: Wed, 23 Jul 2003 12:56:25 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030723125625.77eda939.davem@redhat.com>
References: <200307231428.KAA15254@raptor.research.att.com>
	<20030723074615.25eea776.davem@redhat.com>
	<200307231656.MAA69129@raptor.research.att.com>
	<20030723100043.18d5b025.davem@redhat.com>
	<200307231724.NAA90957@raptor.research.att.com>
	<20030723103135.3eac4cd2.davem@redhat.com>
	<200307231814.OAA74344@raptor.research.att.com>
	<20030723112307.5b8ae55c.davem@redhat.com>
	<200307231854.OAA90112@raptor.research.att.com>
	<20030723120457.206dc02d.davem@redhat.com>
	<200307231911.PAA35164@raptor.research.att.com>
	<20030723121436.10d53965.davem@redhat.com>
	<200307231929.PAA77754@raptor.research.att.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: gsf@research.att.com, dgk@research.att.com, linux-kernel@vger.kernel.org,
   netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Glenn Fowler <gsf@research.att.com>
In-Reply-To: <200307231929.PAA77754@raptor.research.att.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 23 Jul 2003 15:29:03 -0400 (EDT)
Glenn Fowler <gsf@research.att.com> wrote:

> linux has ioctl(I_PEEK) for stream devices and recv() for sockets,
> and neither of these work on pipes; if there is a linux alternative
> for pipes then we'd be glad to use it

Alan mentioned the pure-socket namespace we have for named unix
sockets, but I don't think you can actually use it for your
problem unfortunately.
