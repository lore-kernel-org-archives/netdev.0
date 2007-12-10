From: Sam Ravnborg <sam@ravnborg.org>
Subject: Re: [PATCH RFC] [5/9] modpost: Fix a buffer overflow in modpost
Date: Mon, 10 Dec 2007 21:07:46 +0100
Message-ID: <20071210200746.GA17700@uranus.ravnborg.org>
References: <20071122343.446909000@suse.de> <20071122024310.BB7E414D68@wotan.suse.de> <20071210193202.GC17315@uranus.ravnborg.org> <200712102057.29016.ak@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	rusty@rustcorp.com.au
To: Andi Kleen <ak@suse.de>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1758078AbXLJUGS@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <200712102057.29016.ak@suse.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Dec 10, 2007 at 08:57:28PM +0100, Andi Kleen wrote:
> On Monday 10 December 2007 20:32, Sam Ravnborg wrote:
> > On Thu, Nov 22, 2007 at 03:43:10AM +0100, Andi Kleen wrote:
> > > When passing an file name > 1k the stack could be overflowed.
> > > Not really a security issue, but still better plugged.
> >
> > Looks good. A s-o-b line again please.
> 
> Signed-off-by: Andi Kleen <ak@suse.de>
> 
> > Although I am not so happy with the ue of gcc extensions.
> 
> That's not a gcc extension. It's C99.

OK.
I have applied all three patches to kbuild.git.

As I did not follow the whole thread about the namespace I did not
take those.
And the first patch touching module.c should go in via akpm I think.
It is outside my core-competence area at least .

	Sam
