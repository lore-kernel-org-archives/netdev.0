From: Andrea Arcangeli <andrea@novell.com>
Subject: Re: The ultimate TOE design
Date: Thu, 16 Sep 2004 03:05:09 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040916010509.GP15426@dualathlon.random>
References: <4148991B.9050200@pobox.com> <Pine.LNX.4.61.0409152102050.23011@fogarty.jakma.org> <1095275660.20569.0.camel@localhost.localdomain> <20040915135308.78bf74f0.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>, paul@clubi.ie, netdev@oss.sgi.com,
        leonid.grossman@s2io.com, linux-kernel@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20040915135308.78bf74f0.davem@davemloft.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, Sep 15, 2004 at 01:53:08PM -0700, David S. Miller wrote:
> There are absolutely no justified economics in these
> TOE engines.  By the time you deploy them, the cpus
> and memory catch up and what's more those are general
> purpose and not just for networking as David Stevens
> and others have said.

I'm not sure if economics are the worst part of what is being shipped,
to me the worst part is security, I'd never trust myself such a
non-open-source TCP stack for something critical even if it was going to
be much cheaper and performant. Even my PDA is using the linux tcp
stack, and my cell phone only speaks UDP with the wap server anyways.
TCP segment offload OTOH doesn't involve much "intelligence" in the NIC
and it's very reasonable to trust it especially because all the incoming
packets (the real potential offenders) are still processed by the linux
tcp stack.
