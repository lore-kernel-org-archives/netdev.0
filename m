From: Andi Kleen <ak@suse.de>
Subject: Re: [PATCH RFC] [5/9] modpost: Fix a buffer overflow in modpost
Date: Mon, 10 Dec 2007 20:57:28 +0100
Message-ID: <200712102057.29016.ak@suse.de>
References: <20071122343.446909000@suse.de> <20071122024310.BB7E414D68@wotan.suse.de> <20071210193202.GC17315@uranus.ravnborg.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	rusty@rustcorp.com.au
To: Sam Ravnborg <sam@ravnborg.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns.suse.de ([195.135.220.2]:45743 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754703AbXLJT5u (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 10 Dec 2007 14:57:50 -0500
In-Reply-To: <20071210193202.GC17315@uranus.ravnborg.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Monday 10 December 2007 20:32, Sam Ravnborg wrote:
> On Thu, Nov 22, 2007 at 03:43:10AM +0100, Andi Kleen wrote:
> > When passing an file name > 1k the stack could be overflowed.
> > Not really a security issue, but still better plugged.
>
> Looks good. A s-o-b line again please.

Signed-off-by: Andi Kleen <ak@suse.de>

> Although I am not so happy with the ue of gcc extensions.

That's not a gcc extension. It's C99.

-Andi
