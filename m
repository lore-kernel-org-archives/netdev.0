From: "David S. Miller" <davem@redhat.com>
Subject: Re: kernel bug in socketpair()
Date: Wed, 23 Jul 2003 11:23:07 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030723112307.5b8ae55c.davem@redhat.com>
References: <200307231428.KAA15254@raptor.research.att.com>
	<20030723074615.25eea776.davem@redhat.com>
	<200307231656.MAA69129@raptor.research.att.com>
	<20030723100043.18d5b025.davem@redhat.com>
	<200307231724.NAA90957@raptor.research.att.com>
	<20030723103135.3eac4cd2.davem@redhat.com>
	<200307231814.OAA74344@raptor.research.att.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: gsf@research.att.com, dgk@research.att.com, linux-kernel@vger.kernel.org,
   netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Glenn Fowler <gsf@research.att.com>
In-Reply-To: <200307231814.OAA74344@raptor.research.att.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 23 Jul 2003 14:14:57 -0400 (EDT)
Glenn Fowler <gsf@research.att.com> wrote:

> named sockets seem a little heavyweight for this application

I think it'll be cheaper than unnamed unix sockets and
groveling in /proc/*/fd/

And even if there is a minor performance issue, you'll more than get
that back due to the portability gain. :-)
