From: Jon Masters <jonathan@jonmasters.org>
Subject: Re: [PATCH] netfilter: per netns nf_conntrack_cachep
Date: Thu, 04 Feb 2010 08:42:30 -0500
Message-ID: <1265290950.2861.460.camel@tonnant>
References: <1265108690.2861.118.camel@tonnant>
	 <1265134598.2861.191.camel@tonnant> <4B6870AF.6060109@trash.net>
	 <4B6967BC.600@trash.net> <1265222289.2861.290.camel@tonnant>
	 <20100203190948.GA5182@x200> <1265226227.2861.302.camel@tonnant>
	 <4B6ABCB8.4080904@trash.net>
	 <b6fcc0a1002040427n221da433n755350b4a41bbf9b@mail.gmail.com>
	 <4B6ABDEF.8090005@trash.net>
	 <b6fcc0a1002040435t150aa7axf2dc0b139ed8f258@mail.gmail.com>
	 <4B6AC5DC.60301@trash.net> <1265289486.2861.436.camel@tonnant>
	 <4B6ACD9A.1090905@trash.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Alexey Dobriyan <adobriyan@gmail.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	netfilter-devel <netfilter-devel@vger.kernel.org>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
To: Patrick McHardy <kaber@trash.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4B6ACD9A.1090905@trash.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2010-02-04 at 14:37 +0100, Patrick McHardy wrote:
> Jon Masters wrote:
> > On Thu, 2010-02-04 at 14:04 +0100, Patrick McHardy wrote:
> >> In any case, we need a fix for this suitable for 2.6.33. If
> >> you don't like using the pointer, please send a patch to add
> >> an id to the network namespaces.
> > 
> > Right. I think the quick solution is fine for 2.6.33. So that makes the
> > hashtable non-resize patch, the crash fix, and the cachep bits. I will
> > try to get involved and help you out with the per-ns hashtable clean
> > rather than just being a whiner :)
> 
> This is the patch I'm going to commit unless unless there are further
> objections. Its Eric's patch with a change on top to allocate a unique
> name for the slab.
> 
> > Thanks a bunch! Fedora kernels have already been built with this fix,
> > since it will allow us to close a fair number of "KVM goes boom" bugs.
> 
> Thanks as well for your help.

Patch looks fine to me for the moment, unless it *really* matters about
the pointer exposure.

Jon.
