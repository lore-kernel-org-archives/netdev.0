From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [bernie@develer.com: Kernel 2.6 size increase]
Date: Wed, 23 Jul 2003 20:06:58 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030723200658.A27856@infradead.org>
References: <20030723195355.A27597@infradead.org> <20030723195504.A27656@infradead.org> <20030723115858.75068294.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Content-Disposition: inline
In-Reply-To: <20030723115858.7506829I4.davem@redhat.com>; from davem@redhat.com on Wed, Jul 23, 2003 at 11:58:58AM -0700
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, Jul 23, 2003 at 11:58:58AM -0700, David S. Miller wrote:
> > Sorry, this actually already Cc'ed lkml :)  Still the netdev folks
> > should read it, too.
> 
> Well, we gained some code and a little bit of data, but
> the BSS was cut in half which I think deserves noticing :-)
> 
> Also, he should analyze the amount of code that actually
> gets executed for various tasks, comparing 2.4.x to 2.5.x
> 
> I'd take a half-meg code size hit if it meant that all
> the normal code paths got cut in half :-)

half a megabyte more codesize is a lot if you're based on flash.
I know you absolutely disliked Andi's patch to make the xfrm subsystem
optional so we might need find other ways to make the code smaller
on those systems that need it.  Now I could talk a lot but I'm really
no networking insider so it's hard for me to suggest where to start.
I'll rather look at the fs/ issue but it would be nice if networking
folks could do their part, too.
