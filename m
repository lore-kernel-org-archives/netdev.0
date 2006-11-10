From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [patch 5/5] drivers cris: return on NULL dev_alloc_skb()
Date: Fri, 10 Nov 2006 11:09:55 -0500
Message-ID: <4554A453.1090805@garzik.org>
References: <200611090349.kA93nFUE003603@shell0.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, rientjes@cs.washington.edu,
	starvik@axis.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:14980 "EHLO mail.dvmed.net")
	by vger.kernel.org with ESMTP id S1946721AbWKJQJ5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Nov 2006 11:09:57 -0500
To: akpm@osdl.org
In-Reply-To: <200611090349.kA93nFUE003603@shell0.pdx.osdl.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

akpm@osdl.org wrote:
> From: David Rientjes <rientjes@cs.washington.edu>
> 
> If the next descriptor array entry cannot be allocated by dev_alloc_skb(),
> return immediately so it is not dereferenced later.  We cannot register the
> device with a partial descriptor list.
> 
> Cc: Mikael Starvik <starvik@axis.com>
> Signed-off-by: David Rientjes <rientjes@cs.washington.edu>
> Cc: Jeff Garzik <jeff@garzik.org>
> Signed-off-by: Andrew Morton <akpm@osdl.org>

applied


