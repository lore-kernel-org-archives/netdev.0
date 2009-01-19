From: Harvey Harrison <harvey.harrison@gmail.com>
Subject: Re: [PATCH] bnx2: annotate bp->phy_lock functions
Date: Mon, 19 Jan 2009 12:29:21 -0800
Message-ID: <1232396961.13386.7.camel@brick>
References: <1232395910.13386.4.camel@brick>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	linux-netdev <netdev@vger.kernel.org>
To: Eilon Greenstein <eilong@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wf-out-1314.google.com ([209.85.200.171]:63387 "EHLO
	wf-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753279AbZASUbw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Jan 2009 15:31:52 -0500
Received: by wf-out-1314.google.com with SMTP id 27so3376920wfd.4
        for <netdev@vger.kernel.org>; Mon, 19 Jan 2009 12:31:52 -0800 (PST)
In-Reply-To: <1232395910.13386.4.camel@brick>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2009-01-19 at 12:12 -0800, Harvey Harrison wrote:
> It looks like the locking is OK as the locks were being taken before the
> various phy setup functions, add the annotations as they release and
> reacquire the phy_lock.
> 
> Signed-off-by: Harvey Harrison <harvey.harrison@gmail.com>
> ---

Whoops, bnx2 != bnx2x....that driver needs serious help in the endianess
department, but it doesn't actually lok to hard to sort out as it seems
most of the warnings come about as the hardware structs are just not
annotated, but the correct accessors seem to be in place in the code.

In addition, there are piles of macros in the driver that really shouldn't
be.  I'll have a look this afternoon at some of the low-hanging fruit.

Harvey

