From: Marcelo Tosatti <marcelo.tosatti@cyclades.com>
Subject: Re: [Lse-tech] Re: A common layer for Accounting packages
Date: Mon, 28 Feb 2005 06:52:04 -0300
Message-ID: <20050228095204.GH23606@logos.cnet>
References: <20050227094949.GA22439@logos.cnet> <4221E548.4000008@ak.jp.nec.com> <20050227140355.GA23055@logos.cnet> <42227AEA.6050002@ak.jp.nec.com> <1109575236.8549.14.camel@frecb000711.frec.bull.fr> <20050227233943.6cb89226.akpm@osdl.org> <1109592658.2188.924.camel@jzny.localdomain> <20050228132051.GO31837@postel.suug.ch> <1109598010.2188.994.camel@jzny.localdomain> <20050228135307.GP31837@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jamal <hadi@cyberus.ca>, Andrew Morton <akpm@osdl.org>,
        Guillaume Thouvenin <guillaume.thouvenin@bull.net>,
        kaigai@ak.jp.nec.com, "David S. Miller" <davem@redhat.com>,
        jlan@sgi.com, lse-tech@lists.sourceforge.net,
        linux-kernel@vger.kernel.org, netdev@oss.sgi.com,
        elsa-devel@lists.sourceforge.net
To: Thomas Graf <tgraf@suug.ch>
Content-Disposition: inline
In-Reply-To: <20050228135307.GP31837@postel.suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, Feb 28, 2005 at 02:53:07PM +0100, Thomas Graf wrote:
> * jamal <1109598010.2188.994.camel@jzny.localdomain> 2005-02-28 08:40
> > 
> > netlink broadcast or a wrapper around it.
> > Why even bother doing the check with netlink_has_listeners()?
> 
> To implement the master enable/disable switch they want. The messages
> don't get send out anyway but why bother doing all the work if nothing
> will get send out in the end? It implements a well defined flag
> controlled by open/close on fds (thus handles dying applications)
> stating whether the whole code should be enabled or disabled.

Yep - this far from "reinventing the wheel". ;)

> It is of course not needed to avoid sending unnecessary messages.

Thats the goal, thanks.
