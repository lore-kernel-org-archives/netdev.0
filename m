From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: kernel bug in socketpair()
Date: 23 Jul 2003 20:08:21 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1058987301.5520.111.camel@dhcp22.swansea.linux.org.uk>
References: <200307231428.KAA15254@raptor.research.att.com>
	 <20030723074615.25eea776.davem@redhat.com>
	 <200307231656.MAA69129@raptor.research.att.com>
	 <20030723100043.18d5b025.davem@redhat.com>
	 <200307231724.NAA90957@raptor.research.att.com>
	 <20030723103135.3eac4cd2.davem@redhat.com>
	 <200307231814.OAA74344@raptor.research.att.com>
	 <20030723112307.5b8ae55c.davem@redhat.com>
	 <200307231854.OAA90112@raptor.research.att.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: davem@redhat.com, dgk@research.att.com,
   Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
   netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Glenn Fowler <gsf@research.att.com>
In-Reply-To: <200307231854.OAA90112@raptor.research.att.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mer, 2003-07-23 at 19:54, Glenn Fowler wrote:
> named unix sockets reside in the fs namespace, no?
> so they must be linked to a dir before use and unlinked after use
> the unlink after use would be particularly tricky for the parent process
> implementing
> 	cmd <(cmd ...) ...

Portable stuff yes, Linux also supports a pure socket namespace for them
when the path starts with a nul character
