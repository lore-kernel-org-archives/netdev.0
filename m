From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH] remove dead skb_iter code
Date: Wed, 2 Mar 2005 23:59:22 +0100
Message-ID: <20050302225922.GT31837@postel.suug.ch>
References: <20050302101035.61786113@dxpl.pdx.osdl.net> <20050302102025.23f479f9.davem@davemloft.net> <20050302220735.GB25847@infradead.org> <20050302142542.2ae86040.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Christoph Hellwig <hch@infradead.org>, shemminger@osdl.org,
        netdev@oss.sgi.com
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20050302142542.2ae86040.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

* David S. Miller <20050302142542.2ae86040.davem@davemloft.net> 2005-03-02 14:25
> On Wed, 2 Mar 2005 22:07:35 +0000
> Christoph Hellwig <hch@infradead.org> wrote:
> 
> > Maybe because the removal is right.  This code is not dependent on
> > any networking internals so it can easily live in a netfilter support
> > module instead of bloating everyones kernels.
> 
> Fine, I'll kill it for now.  (I also happen to know that it might
> be used for ipv4 fragmentation tricks too, but that's also in the
> future).

It will be used for the string matching API shared by netfilter
and ematches. Not sure yet whether it will live in lib/ or net/netfilter
though.
