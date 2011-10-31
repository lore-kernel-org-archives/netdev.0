From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] 3c505: Fix compile breakage
Date: Mon, 31 Oct 2011 17:57:43 -0400 (EDT)
Message-ID: <20111031.175743.115974002318620455.davem@davemloft.net>
References: <4EAF0F34.4070702@panasas.com>
	<1320097524.4399.8.camel@Joe-Laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bharrosh@panasas.com, jbaron@redhat.com, philb@gnu.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	randy.dunlap@oracle.com, sfr@canb.auug.org.au
To: joe@perches.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1320097524.4399.8.camel@Joe-Laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Joe Perches <joe@perches.com>
Date: Mon, 31 Oct 2011 23:45:24 +0200

> The joys of preprocessor games with c90 named initializers.
> 
> commit 07613b0b5ef8
> ("dynamic_debug: consolidate repetitive struct _ddebug descriptor definitions")
> uses a ".filename" named initializer.
> 
> When filename is also a #define this fails to compile.
> 
> Remove #define filename from 3c505.c
> 
> Signed-off-by: Joe Perches <joe@perches.com>

Andrew Morton submitted a fix for this earlier today.

http://marc.info/?l=linux-netdev&m=132009089027792&w=2
