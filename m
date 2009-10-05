From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: Support inclusion of <linux/socket.h> before
 <sys/socket.h>
Date: Mon, 05 Oct 2009 00:24:45 -0700 (PDT)
Message-ID: <20091005.002445.248925509.davem@davemloft.net>
References: <1254627764.2395.48.camel@localhost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, waldi@debian.org, manuel@debian.org,
	538372@bugs.debian.org
To: ben@decadent.org.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58641
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754969AbZJEHYu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Oct 2009 03:24:50 -0400
In-Reply-To: <1254627764.2395.48.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <ben@decadent.org.uk>
Date: Sun, 04 Oct 2009 04:42:44 +0100

> From: Bastian Blank <waldi@debian.org>
> 
> The following user-space program fails to compile:
> 
>     #include <linux/socket.h>
>     #include <sys/socket.h>
>     int main() { return 0; }
> 
> The reason is that <linux/socket.h> tests __GLIBC__ to decide whether it
> should define various structures and macros that are now defined for
> user-space by <sys/socket.h>, but __GLIBC__ is not defined if no libc
> headers have yet been included.
> 
> It seems safe to drop support for libc 5 now.
> 
> Signed-off-by: Ben Hutchings <ben@decadent.org.uk>

Fair enough, applied to net-2.6, thanks.
