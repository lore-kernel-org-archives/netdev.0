From: Dave Jones <davej@redhat.com>
Subject: Re: [PATCH RFC] [1/9] Core module symbol namespaces code and intro.
Date: Tue, 27 Nov 2007 14:00:37 -0500
Message-ID: <20071127190037.GB30057@redhat.com>
References: <20071122343.446909000@suse.de> <adatznarrzc.fsf@cisco.com> <200711261228.15155.rusty@rustcorp.com.au> <20071126102533.1c774870@freepuppy.rosehill.pdx.hemminger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Rusty Russell <rusty@rustcorp.com.au>,
	Roland Dreier <rdreier@cisco.com>, Andi Kleen <ak@suse.de>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	sam@ravnborg.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:32931 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756834AbXK0TAv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Nov 2007 14:00:51 -0500
Content-Disposition: inline
In-Reply-To: <20071126102533.1c774870@freepuppy.rosehill.pdx.hemminger.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Nov 26, 2007 at 10:25:33AM -0800, Stephen Hemminger wrote:
 
 > 1) Why is everyone so concerned that export symbol space is large?
 > 	- does it cost cpu or running memory?
 > 	- does it cause bugs?
 > 	- or are you just worried about "evil modules"?

To clarify something here, by "evil", don't necessarily think "binary only". 

Out of tree modules are frequently using symbols that they shouldn't be.
Because they get no peer-review here, they 'get away with it' for the most part.
Until distro vendors push rebased kernel updates that removed exports that
should never have been exported, and suddenly people like me get bombed
with "Fedora broke my xyz driver" mails.

Reducing the opportunity for people to screw things up is a good thing.
If a symbol is exported, most out-of-tree driver authors seem to
think its "fair game" to use it.

	Dave

-- 
http://www.codemonkey.org.uk
