From: James Morris <jmorris@namei.org>
Subject: Re: [RFC PATCH v6 00/16] Labeled networking patches for 2.6.28
Date: Thu, 2 Oct 2008 08:14:01 +1000 (EST)
Message-ID: <alpine.LRH.1.10.0810020812400.12028@tundra.namei.org>
References: <20080916124722.17132.38741.stgit@flek.lan> <alpine.LRH.1.10.0810011128240.5277@tundra.namei.org> <200810011224.26106.paul.moore@hp.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: selinux@tycho.nsa.gov, linux-security-module@vger.kernel.org,
	netdev@vger.kernel.org
To: Paul Moore <paul.moore@hp.com>
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <200810011224.26106.paul.moore@hp.com>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 1 Oct 2008, Paul Moore wrote:

> On Tuesday 30 September 2008 9:34:24 pm James Morris wrote:
> > I found some sparse warnings -- the last couple at least may need
> > attention:
> >
> > $ make C=2 CF="-D__cold__=" SUBDIRS=net/netlabel
> 
> Ah ha!
> 
> At this point I have to admit a dirty little secret, I've never run 
> sparse on any of my code before.  It isn't for a lack of trying it is 
> just that I had no idea how to do so and googling for "sparse" and all 
> the relevant Linux modifiers didn't result in much.  That command line 
> helped quite a bit.
> 
> For others who may be interested you can find the sparse tool here:
> 
>  * http://www.kernel.org/pub/software/devel/sparse
> 
> ... and it looks like the magic incantation is "make C={1,2}".  I have 
> no idea what the "CF=..." bits do, James?

This creates CFLAGS, which are needed to make the __cold__ thing go away 
(no idea what that is), which you'll see if you don't inlcude the -CF 
thing.


-- 
James Morris
<jmorris@namei.org>
