From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH] [IPV4]: Exclude "All deletion of equal addresses only differing by prefix length."
Date: Thu, 31 Mar 2005 20:26:19 +0200
Message-ID: <20050331182619.GW3086@postel.suug.ch>
References: <20050331124747.GT3086@postel.suug.ch> <Pine.LNX.4.61.0503312047110.26294@netcore.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Pekka Savola <pekkas@netcore.fi>
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.61.0503312047110.26294@netcore.fi>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

* Pekka Savola <Pine.LNX.4.61.0503312047110.26294@netcore.fi> 2005-03-31 20:48
> On Thu, 31 Mar 2005, Thomas Graf wrote:
> >The address deletion fix is no longer needed since a better fix
> >has made it into iproute2. Better in terms of same hack but in
> >userspace so we don't confuse other netlink users.
> 
> So, does that mean that all the users are expected to always run the 
> latest iproute2, so there's no need for backward-compat in the kernel?

The actual challenge in this rather trivial problem is that many scripts
rely on this wrong behaviour by doing ip a a 1.1.1.1/24 dev lo;
ip a d 1.1.1.1 dev lo; and nobody wants to break them. So even with the
kernel fix we had, old iproute2 versions still did it wrong but it gave
newer iproute2 versions a chance to work around the issue.
