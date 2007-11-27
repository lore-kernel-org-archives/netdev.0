From: Adrian Bunk <bunk@kernel.org>
Subject: Re: [PATCH RFC] [1/9] Core module symbol namespaces code and intro.
Date: Tue, 27 Nov 2007 19:59:53 +0100
Message-ID: <20071127185952.GD3406@stusta.de>
References: <20071122343.446909000@suse.de> <200711261228.15155.rusty@rustcorp.com.au> <adahcj9sfan.fsf@cisco.com> <200711271549.37670.rusty@rustcorp.com.au> <1196141742.9876.49.camel@trinity.ogc.int> <20071127171542.GB3406@stusta.de> <1196185537.24469.21.camel@trinity.ogc.int>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Rusty Russell <rusty@rustcorp.com.au>,
	Roland Dreier <rdreier@cisco.com>, Andi Kleen <ak@suse.de>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	sam@ravnborg.org
To: Tom Tucker <tom@opengridcomputing.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from emailhub.stusta.mhn.de ([141.84.69.5]:33991 "EHLO
	mailhub.stusta.mhn.de" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1756834AbXK0TAE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Nov 2007 14:00:04 -0500
Content-Disposition: inline
In-Reply-To: <1196185537.24469.21.camel@trinity.ogc.int>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Nov 27, 2007 at 11:45:37AM -0600, Tom Tucker wrote:
> 
> On Tue, 2007-11-27 at 18:15 +0100, Adrian Bunk wrote:
> > On Mon, Nov 26, 2007 at 11:35:42PM -0600, Tom Tucker wrote:
> > > On Tue, 2007-11-27 at 15:49 +1100, Rusty Russell wrote:
> > >...
> > > > No.  That's the wrong question.  What's the real upside?
> > > 
> > > Explicitly documenting what comprises the kernel API (external,
> > > supported) and what comprises the kernel implementation (internal, not
> > > supported).
> > >...
> > 
> > There is not, never was, and never will be, any supported external API 
> > of the kernel.
> 
> Philosophically I understand what you're saying, but in practical terms
> there is the issue of managing core API like kmalloc. Although kmalloc
> _could_ change, doing so would be extremely painful. In fact anyone who
> proposed such a change would have to have a profoundly powerful argument
> as to why it was necessary.

The latter should at least in theory be required for all changes no 
matter how core they are...

> I think this patchset is an attempt to make it easier to identify and
> review these kinds of interfaces.

As long as the submitter fixes all in-kernel users these interfaces are 
not handled differently from interfaces with fewer users.

And I remember at least one commit that changed > 1000 files because it 
changed a frequently used driver API. [1]

cu
Adrian

[1] commit 7d12e780e003f93433d49ce78cfedf4b4c52adc5

-- 

       "Is there not promise of rain?" Ling Tan asked suddenly out
        of the darkness. There had been need of rain for many days.
       "Only a promise," Lao Er said.
                                       Pearl S. Buck - Dragon Seed

