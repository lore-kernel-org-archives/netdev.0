From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [bernie@develer.com: Kernel 2.6 size increase]
Date: Wed, 23 Jul 2003 20:13:35 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030723201335.A27990@infradead.org>
References: <20030723195355.A27597@infradead.org> <20030723195504.A27656@infradead.org> <20030723115858.75068294.davem@redhat.com> <20030723200658.A27856@infradead.org> <20030723120901.57746fd8.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Christoph Hellwig <hch@infradead.org>, linux-kernel@vger.kernel.org,
   netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Content-Disposition: inline
In-Reply-To: <20030723120901.57746fd8.davem@redhat.com>; from davem@redhat.com on Wed, Jul 23, 2003 at 12:09:01PM -0700
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, Jul 23, 2003 at 12:09:01PM -0700, David S. Miller wrote:
> So basically we'd have a CONFIG_NET_XFRM, and things like
> AH/ESP/IPCOMP/AH6/ESP6/IPCOMP6 would say "select NET_XFRM"
> in the Kconfig where they are selected.
> 
> Then when CONFIG_NET_XFRM is not set all the xfrm interfaces
> called from non-ipsec non-xfrm source files get NOP versions.
> 
> Is this exactly what Andi's patch did?  Just send it on
> so we can integrate this.

I think that's what it did modula the select which IIRC wasn't
available back then.  But I guess I'll rather leave this to
Andi.

> We actually lost a lot of code in other areas of the networking, for
> example Andrew Morton and I made many bogus function inlines
> undone because they made the code too large.

That's cool!  Now we just need to find a bunch more regressions
and actually make 2.6 smaller than 2.4 :)  Of course that's true
for the other subsystems, too.
