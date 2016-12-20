From: Dave Jones <davej@codemonkey.org.uk>
Subject: Re: ipv6: handle -EFAULT from skb_copy_bits
Date: Mon, 19 Dec 2016 19:40:13 -0500
Message-ID: <20161220004013.43pcopemc6im32az@codemonkey.org.uk>
References: <20161214154729.g4yg4mxcgkvpe5w7@codemonkey.org.uk>
 <20161217.104120.945262627572958024.davem@davemloft.net>
 <20161219170320.nnezhql2vj5mrrrp@codemonkey.org.uk>
 <20161219.144848.736886978545428136.davem@davemloft.net>
 <20161220003144.omoqyghgdfbxdyuu@codemonkey.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from arcturus.aphlor.org ([188.246.204.175]:50886 "EHLO
        arcturus.aphlor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753219AbcLTAkT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 19 Dec 2016 19:40:19 -0500
Content-Disposition: inline
In-Reply-To: <20161220003144.omoqyghgdfbxdyuu@codemonkey.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Dec 19, 2016 at 07:31:44PM -0500, Dave Jones wrote:

 > Unfortunately, this made no difference.  I spent some time today trying
 > to make a better reproducer, but failed. I'll revisit again tomorrow.
 > 
 > Maybe I need >1 process/thread to trigger this.  That would explain why
 > I can trigger it with Trinity.

scratch that last part, I finally just repro'd it with a single process.

	Dave
