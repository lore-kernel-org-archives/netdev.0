From: Chris Wedgwood <cw@f00f.org>
Subject: Re: Off-by-one bug at unix_mkname ?
Date: Mon, 28 Mar 2005 00:49:53 -0800
Message-ID: <20050328084953.GA3712@taniwha.stupidest.org>
References: <200503281700.HHE91205.FtVLOStGOSPMYJFMN@I-love.sakura.ne.jp> <20050328.172108.30349253.yoshfuji@linux-ipv6.org> <20050328.173938.26746686.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, linux-kernel@vger.kernel.org,
	netdev@oss.sgi.com, from-linux-kernel@I-love.sakura.ne.jp
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S261358AbVC1Iuy@vger.kernel.org>
To: "YOSHIFUJI Hideaki / ?$B5HF#1QL@" <yoshfuji@linux-ipv6.org>
Content-Disposition: inline
In-Reply-To: <20050328.173938.26746686.yoshfuji@linux-ipv6.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Mar 28, 2005 at 05:39:38PM +0900, YOSHIFUJI Hideaki / ?$B5HF#1QL@ wrote:

> +		/*
> +		 *	This may look like an off by one error but it is
> +		 *	a bit more subtle. 108 is the longest valid AF_UNIX
> +		 *	path for a binding. sun_path[108] doesnt as such
> +		 *	exist. However in kernel space we are guaranteed that
> +		 *	it is a valid memory location in our kernel
> +		 *	address buffer.

icky pointless white space?

> +		 */
> +		if (len > sizeof(*sunaddr))

what?
