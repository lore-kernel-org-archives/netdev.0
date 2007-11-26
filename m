From: Roland Dreier <rdreier@cisco.com>
Subject: Re: [PATCH RFC] [1/9] Core module symbol namespaces code and intro.
Date: Mon, 26 Nov 2007 14:18:25 -0800
Message-ID: <adave7or6q6.fsf@cisco.com>
References: <20071122343.446909000@suse.de> <adatznarrzc.fsf@cisco.com>
	<200711261228.15155.rusty@rustcorp.com.au>
	<20071126102533.1c774870@freepuppy.rosehill.pdx.hemminger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Rusty Russell <rusty@rustcorp.com.au>, Andi Kleen <ak@suse.de>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	sam@ravnborg.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1757018AbXKZWSr@vger.kernel.org>
In-Reply-To: <20071126102533.1c774870@freepuppy.rosehill.pdx.hemminger.net> (Stephen Hemminger's message of "Mon, 26 Nov 2007 10:25:33 -0800")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

 > Agreed. On first glance, I was intrigued but:
 > 
 > 1) Why is everyone so concerned that export symbol space is large?
 > 	- does it cost cpu or running memory?
 > 	- does it cause bugs?
 > 	- or are you just worried about "evil modules"?
 > 
 > 2) These aren't real namespaces
 > 	- all global names still have to be unique
 > 	- still have to handle the "non-modular build" namespace conflicts
 > 	- there isn't a big problem with conflicting symbols today.

Perhaps changing the name from "namespace" to "interface" would help?
Then a module could have something like

MODULE_USE_INTERFACE(foo);

and I think that makes it clearer what the advantage of this is: it
marks symbols as being part of a certain interface, requires modules
that use that interface to declare that use explicitly, and allows
reviewers to say "Hey why is this code using the scsi interface when
it's a webcam driver?"

 - R.
