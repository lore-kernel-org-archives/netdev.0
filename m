From: James Morris <jmorris@redhat.com>
Subject: Re: [RFC][PATCH 2/3] netlink check sender, audit
Date: Tue, 15 Feb 2005 22:42:47 -0500 (EST)
Message-ID: <Xine.LNX.4.44.0502152239520.32502-100000@thoron.boston.redhat.com>
References: <20050216001120.GJ15867@shell0.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Pablo Neira <pablo@eurodev.net>, <netdev@oss.sgi.com>,
        <davem@davemloft.net>, <sds@epoch.ncsc.mil>, <serue@us.ibm.com>
To: Chris Wright <chrisw@osdl.org>
In-Reply-To: <20050216001120.GJ15867@shell0.pdx.osdl.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 15 Feb 2005, Chris Wright wrote:

> * Pablo Neira (pablo@eurodev.net) wrote:
> > I was aware of that. Actually I think that we can modify all calls to 
> > netlink_kernel_create (that aren't that much) to fit the new interface, 
> > I can post a patch to do that. I prefer providing just one function to 
> > create a netlink socket in kernel space.
> 
> My only thought is as an exported symobl it's harder to be clear on
> who's using it (possibly out-of-tree).

Doesn't matter, the kernel has no ABI.

http://www.kroah.com/log/linux/stable_api_nonsense.html?seemore=y



- James
-- 
James Morris
<jmorris@redhat.com>
