From: Glenn Fowler <gsf@research.att.com>
Subject: Re: kernel bug in socketpair()
Date: Wed, 23 Jul 2003 15:11:47 -0400 (EDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200307231911.PAA35164@raptor.research.att.com>
References: <200307231428.KAA15254@raptor.research.att.com>  <20030723074615.25eea776.davem@redhat.com>  <200307231656.MAA69129@raptor.research.att.com>  <20030723100043.18d5b025.davem@redhat.com>  <200307231724.NAA90957@raptor.research.att.com>  <20030723103135.3eac4cd2.davem@redhat.com>  <200307231814.OAA74344@raptor.research.att.com>  <20030723112307.5b8ae55c.davem@redhat.com>  <200307231854.OAA90112@raptor.research.att.com> <20030723120457.206dc02d.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dgk@research.att.com, linux-kernel@vger.kernel.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com, gsf@research.att.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


On Wed, 23 Jul 2003 12:04:57 -0700 David S. Miller wrote:
> Is bash totally broken because of all this?  Or does the problem only
> trigger when using (cmd) subprocesses in a certain way?

bash uses pipe() so its ok
using socketpair() instead of pipe() introduces the problem
and we will now have to find an alternative to work around the
linux /dev/fd/N implementation

thanks
