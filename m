From: Harvey Harrison <harvey.harrison@gmail.com>
Subject: Re: [RFC PATCH] kernel: add byteorder macros with alignment fixups
Date: Thu, 20 Mar 2008 11:37:24 -0700
Message-ID: <1206038244.17059.7.camel@brick>
References: <1206034454.17059.4.camel@brick>
	 <20080320182911.GQ10722@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>,
	LKML <linux-kernel@vger.kernel.org>,
	linux-netdev <netdev@vger.kernel.org>
To: Al Viro <viro@ZenIV.linux.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from el-out-1112.google.com ([209.85.162.182]:13042 "EHLO
	el-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753809AbYCTSha (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Mar 2008 14:37:30 -0400
Received: by el-out-1112.google.com with SMTP id v27so817859ele.17
        for <netdev@vger.kernel.org>; Thu, 20 Mar 2008 11:37:29 -0700 (PDT)
In-Reply-To: <20080320182911.GQ10722@ZenIV.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2008-03-20 at 18:29 +0000, Al Viro wrote:
> On Thu, Mar 20, 2008 at 10:34:14AM -0700, Harvey Harrison wrote:
> > A common pattern in the kernel (especially networking) is:
> > 
> > le32_to_cpu(get_unaligned((__le32 *)x));
> > 
> > Repeat for various combinations of le/be and 64/32/16 bit.  Add
> > a variant that operates on possibly unaligned pointers to
> > byteorder/generic.h
> 
> ... and asm/unaligned.h has just acquired fuckloads of places including
> it indirectly.  Not Nice(tm).

Time for linux/unaligned.h?

Do you think the helpers are worth it...wherever they end up?

Harvey

