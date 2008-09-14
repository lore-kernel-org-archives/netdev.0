From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [patch 03/12] sundance: set carrier status on link change events
Date: Sat, 13 Sep 2008 20:13:34 -0400
Message-ID: <48CC572E.40604@garzik.org>
References: <200808202351.m7KNpxBh006024@imap1.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dbn.lists@gmail.com
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:38141 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753040AbYINANh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 13 Sep 2008 20:13:37 -0400
In-Reply-To: <200808202351.m7KNpxBh006024@imap1.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

akpm@linux-foundation.org wrote:
> From: Dan Nicholson <dbn.lists@gmail.com>
> 
> Check if the link is available when a changed interrupt has been received and
> set the carrier status appropriately.  The code is copied nearly verbatim from
> the dl2k module.  The link status could be used in more places in the driver,
> but this is enough to get the carrier status reported to userspace.  Fixes
> kernel bug #7487:
> 
>     http://bugzilla.kernel.org/show_bug.cgi?id=7487
> 
> [akpm@linux-foundation.org: coding-style fixes]
> Signed-off-by: Dan Nicholson <dbn.lists@gmail.com>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> ---
> 
>  drivers/net/sundance.c |   95 +++++++++++++++++++++++++--------------
>  1 file changed, 62 insertions(+), 33 deletions(-)

applied


