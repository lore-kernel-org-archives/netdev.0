From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [PATCH RFC] [1/9] Core module symbol namespaces code and intro.
Date: Tue, 27 Nov 2007 15:49:37 +1100
Message-ID: <200711271549.37670.rusty@rustcorp.com.au>
References: <20071122343.446909000@suse.de> <200711261228.15155.rusty@rustcorp.com.au> <adahcj9sfan.fsf@cisco.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Andi Kleen <ak@suse.de>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, sam@ravnborg.org
To: Roland Dreier <rdreier@cisco.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:53336 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750703AbXK0FAX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Nov 2007 00:00:23 -0500
In-Reply-To: <adahcj9sfan.fsf@cisco.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Monday 26 November 2007 17:15:44 Roland Dreier wrote:
>  > Except C doesn't have namespaces and this mechanism doesn't create them.
>  >  So this is just complete and utter makework; as I said before, noone's
>  > going to confuse all those udp_* functions if they're not in the udp
>  > namespace.
>
> I don't understand why you're so opposed to organizing the kernel's
> exported symbols in a more self-documenting way.

No, I was the one who moved exports near their declarations.  That's 
organised.  I just don't see how this new "organization" will help: oh good, 
I won't accidentally use the udp functions any more?!?

> It seems pretty   
> clear to me that having a mechanism that requires modules to make
> explicit which (semi-)internal APIs makes reviewing easier

Perhaps you've got lots of patches were people are using internal APIs they 
shouldn't?

> , makes it 
> easier to communicate "please don't use that API" to module authors,

Well, introduce an EXPORT_SYMBOL_INTERNAL().  It's a lot less code.  But you'd 
still need to show that people are having trouble knowing what APIs to use.

> and takes at least a small step towards bringing the kernel's exported
> API under control.

There is no "exported API" to bring under control.  There are symbols we 
expose for the kernel's own use which can be used by external modules at 
their own risk.  

> What's the real downside? 

No.  That's the wrong question.  What's the real upside?

Let's not put code in the core because "it doesn't seem to hurt".

I'm sure you think there's a real problem, but I'm still waiting for someone 
to *show* it to me.  Then we can look at solutions.

Rusty.
