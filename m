From: David Miller <davem@davemloft.net>
Subject: Re: [RFC patch net/next] net: Hoist assigns from if?
Date: Tue, 15 Jun 2010 10:46:25 -0700 (PDT)
Message-ID: <20100615.104625.179919135.davem@davemloft.net>
References: <1276618932.1586.64.camel@Joe-Laptop.home>
	<20100615.102305.28825768.davem@davemloft.net>
	<1276623750.1586.81.camel@Joe-Laptop.home>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org
To: joe@perches.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52254
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754542Ab0FORqO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Jun 2010 13:46:14 -0400
In-Reply-To: <1276623750.1586.81.camel@Joe-Laptop.home>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joe Perches <joe@perches.com>
Date: Tue, 15 Jun 2010 10:42:30 -0700

> On Tue, 2010-06-15 at 10:23 -0700, David Miller wrote:
>> > What do you think is missing from the gitk file viewer?
>> I don't use the gitk file viewer, I use "git blame".
> 
> I've never thought git blame was very good for changelog
> tracking as it's a static representation at a particular
> commit/rev.
> 
>> Requiring a GUI to get at the information I need is unacceptable.  I
>> often work remotely and use text consoles for everything, even email
>> and web browsing.
> 
> You want an interactive, text-based (curses?) git-blame style
> file viewer with push/pop git rev-list capabilities?
> 
> Something akin to emacs egit?

No, I want "git blame" to tell me where a line of code came from,
rather than who the last turkey was who did some coding style
cleanup.

I don't want something interactive, I want a command line I can
type in which gives me the answer.  "git blame" on the surface
can do this, and most of the time it serves my needs, but as soon
as rabid cleanups enter into the picture, the tool becomes useless.
