From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [PATCH RFC] [1/9] Core module symbol namespaces code and intro.
Date: Wed, 28 Nov 2007 12:34:02 +1100
Message-ID: <200711281234.03381.rusty@rustcorp.com.au>
References: <20071122343.446909000@suse.de> <200711271526.53065.rusty@rustcorp.com.au> <20071127105016.GC24223@one.firstfloor.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Roland Dreier <rdreier@cisco.com>, Andi Kleen <ak@suse.de>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	sam@ravnborg.org
To: Andi Kleen <andi@firstfloor.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1760281AbXK1Cal@vger.kernel.org>
In-Reply-To: <20071127105016.GC24223@one.firstfloor.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tuesday 27 November 2007 21:50:16 Andi Kleen wrote:
> Goals are:
> - Limit the interfaces available for out of tree modules to reasonably
> stable ones that are already used by a larger set of drivers.

Not the goals.  I haven't seen the *problem* yet.

> - Limit size of exported API to make stable ABIs for enterprise
> distributions easier
> [Yes I know that is not a popular topic on l-k, but it's a day-to-day
> problem for these distros and out of tree solutions do not work]

That's a real problem, and I sympathise with the idea of marking symbols as 
externally useful (or, practically, mark internal).

But we now need to decide what's "externally useful".  The currently line for 
exports is simple: someone in-tree needs it.  You dislike the suggestion to 
extend this to "if more than one in-tree needs it it's open".

Currently your criterion seems to be "does the maintainer hate external 
modules?" which I don't think will be what you want...

Cheers,
Rusty.
