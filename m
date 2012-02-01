From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH net-next] net: dev: Convert printks to pr_<level>
Date: Wed, 01 Feb 2012 11:40:29 -0800
Message-ID: <1328125229.18641.17.camel@joe2Laptop>
References: <1327877783.2652.10.camel@joe2Laptop>
	 <1327880872.2652.12.camel@joe2Laptop> <1327882830.2652.16.camel@joe2Laptop>
	 <20120201.142156.871464551711177387.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120201.142156.871464551711177387.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2012-02-01 at 14:21 -0500, David Miller wrote:
> From: Joe Perches <joe@perches.com>
> Date: Sun, 29 Jan 2012 16:20:30 -0800
> > -		pr_warning("Number of in use tx queues changed "
> > -			   "invalidating tc mappings. Priority "
> > -			   "traffic classification disabled!\n");
> > +		pr_warn(
> > +"Number of in use tx queues changed invalidating tc mappings. "
> > +"Priority traffic classification disabled!\n");
> Don't do things like this.  It is never correct to un-indent subsequent
> lines of a string like this.  And a line ending in "pr_whatever(" looks
> terrible.

I don't care much one way or another about it.
There are a few different uses in that file already.

I do try to avoid having the compiler do string
coalescing.  In this case, I thought it unlikely
that a person would grep with content from both
sentences though.

Coalesced, this format is:

"Number of in use tx queues changed invalidating tc mappings. Priority traffic classification disabled!\n"

105 chars.  That's pretty long.
Do you prefer coalesced formats in all cases?

		pr_warn("Number of in use tx queues changed invalidating tc mappings. Priority traffic classification disabled!\n");
