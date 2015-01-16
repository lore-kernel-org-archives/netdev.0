From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 7/9] rhashtable: Per bucket locks & deferred
 expansion/shrinking
Date: Fri, 16 Jan 2015 16:51:29 +0000
Message-ID: <20150116165129.GN30132@acer.localdomain>
References: <cover.1418647641.git.tgraf@suug.ch>
 <75db38bc9313a55cf02a8c36a3376c32b691e5d9.1418647641.git.tgraf@suug.ch>
 <20150116153415.GF30132@acer.localdomain>
 <20150116155835.GA15052@casper.infradead.org>
 <20150116160354.GI30132@acer.localdomain>
 <20150116161530.GC15052@casper.infradead.org>
 <20150116163202.GJ30132@acer.localdomain>
 <20150116163826.GD15052@casper.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	kernel@vger.kernel.org, herbert@gondor.apana.org.au,
	paulmck@linux.vnet.ibm.com, edumazet@google.com,
	john.r.fastabend@intel.com, josh@joshtriplett.org,
	netfilter-devel@vger.kernel.org
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20150116163826.GD15052@casper.infradead.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 16.01, Thomas Graf wrote:
> On 01/16/15 at 04:32pm, Patrick McHardy wrote:
> > If we have to block, the dumper if of course preferred. Taking the
> > mutex should do fine I guess?
> 
> That will work, it will also ensure that the walker doesn't see the
> pre unzip state which would cause entries to be duplicated in the
> walker.
> 
> > I suppose walking both tables without any races would be rather
> > complicated.
> 
> Very interested if you can come up with something ;-)

For now I'll stick to the mutex. Thanks!
