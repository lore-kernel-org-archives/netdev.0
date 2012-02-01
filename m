From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: dev: Convert printks to pr_<level>
Date: Wed, 01 Feb 2012 14:21:56 -0500 (EST)
Message-ID: <20120201.142156.871464551711177387.davem@davemloft.net>
References: <1327877783.2652.10.camel@joe2Laptop>
	<1327880872.2652.12.camel@joe2Laptop>
	<1327882830.2652.16.camel@joe2Laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: joe@perches.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1327882830.2652.16.camel@joe2Laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Joe Perches <joe@perches.com>
Date: Sun, 29 Jan 2012 16:20:30 -0800

> -		pr_warning("Number of in use tx queues changed "
> -			   "invalidating tc mappings. Priority "
> -			   "traffic classification disabled!\n");
> +		pr_warn(
> +"Number of in use tx queues changed invalidating tc mappings. "
> +"Priority traffic classification disabled!\n");

Don't do things like this.  It is never correct to un-indent subsequent
lines of a string like this.  And a line ending in "pr_whatever(" looks
terrible.
