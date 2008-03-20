From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: [RFC PATCH] kernel: add byteorder macros with alignment fixups
Date: Thu, 20 Mar 2008 18:29:11 +0000
Message-ID: <20080320182911.GQ10722@ZenIV.linux.org.uk>
References: <1206034454.17059.4.camel@brick>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@linux-foundation.org>,
	LKML <linux-kernel@vger.kernel.org>,
	linux-netdev <netdev@vger.kernel.org>
To: Harvey Harrison <harvey.harrison@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:43104 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753370AbYCTS3O (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Mar 2008 14:29:14 -0400
Content-Disposition: inline
In-Reply-To: <1206034454.17059.4.camel@brick>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 20, 2008 at 10:34:14AM -0700, Harvey Harrison wrote:
> A common pattern in the kernel (especially networking) is:
> 
> le32_to_cpu(get_unaligned((__le32 *)x));
> 
> Repeat for various combinations of le/be and 64/32/16 bit.  Add
> a variant that operates on possibly unaligned pointers to
> byteorder/generic.h

... and asm/unaligned.h has just acquired fuckloads of places including
it indirectly.  Not Nice(tm).
