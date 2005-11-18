From: Matt Mackall <mpm@selenic.com>
Subject: Re: [2.6 patch] move some code to net/ipx/af_ipx.c
Date: Fri, 18 Nov 2005 09:27:27 -0800
Message-ID: <20051118172727.GB31287@waste.org>
References: <6.282480653@selenic.com> <7.282480653@selenic.com> <20051114015707.GB5735@stusta.de> <20051118052252.GG11494@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: acme@conectiva.com.br, Andrew Morton <akpm@osdl.org>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1030259AbVKRRa1@vger.kernel.org>
To: Adrian Bunk <bunk@stusta.de>
Content-Disposition: inline
In-Reply-To: <20051118052252.GG11494@stusta.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Nov 18, 2005 at 06:22:52AM +0100, Adrian Bunk wrote:
> > 
> > This patch isn't bad, but looking closer we could move the contents of 
> > p8023.c as well as the contents of at least p8022.c and pe2.c into 
> > af_ipx.c.
> > 
> > Is the contents of any of these three files expected to be used
> > outside IPX (closest candidate would be appletalk)?
> 
> Below is a patch implementing what I was thinking of.

Looks reasonable.

-- 
Mathematics is the supreme nostalgia of our time.
