From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [GIT] Networking
Date: Fri, 11 Mar 2011 23:09:41 -0500
Message-ID: <20110312040941.GA15526@home.goodmis.org>
References: <20110310.155556.48513201.davem@davemloft.net>
 <AANLkTik3AyFTNoytebmOOZ=JSFMkt0bw7au-CSncUHJu@mail.gmail.com>
 <20110311204823.GB7906@fieldses.org>
 <20110311.130128.71121155.davem@davemloft.net>
 <1299878274.2814.8.camel@bwh-desktop>
 <20110311214209.GB9404@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	David Miller <davem@davemloft.net>,
	torvalds@linux-foundation.org, akpm@linux-foundation.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hrndva-omtalb.mail.rr.com ([71.74.56.122]:57122 "EHLO
	hrndva-omtalb.mail.rr.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751053Ab1CLEJq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Mar 2011 23:09:46 -0500
Content-Disposition: inline
In-Reply-To: <20110311214209.GB9404@fieldses.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 11, 2011 at 04:42:09PM -0500, J. Bruce Fields wrote:
> 
> But assume you only did this in cases where the merge was trivial.
> Would it be worth it, or would people be annoyed by the additional
> branching?
> 

I would be annoyed by it ;)

It really is meaningless to do so, as all you are doing is documenting
what commit caused this bug, and producing more problems by branching
off of the broken commit. It wont matter till it is merged, but then if
there are a lot of simple bug fixes, then you will have a lot of single
merges of branches that fix those bugs.

It's just better to say in the change log of the fix:

 "commit abcdef1234 foo: add bar"

Broke this, and this fixes it.

Having the broken commit SHA1 and description in the change log is just
as helpful as having the bug commit being its parent.

-- Steve

