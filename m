From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [patch 08/11] drivers/net/tokenring/3c359.c: squish a warning
Date: Thu, 22 May 2008 06:04:00 -0400
Message-ID: <48354510.70306@garzik.org>
References: <200805142320.m4ENKF7C026632@imap1.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, greg@kroah.com
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:44682 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1763454AbYEVKEC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 May 2008 06:04:02 -0400
In-Reply-To: <200805142320.m4ENKF7C026632@imap1.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

akpm@linux-foundation.org wrote:
> From: Andrew Morton <akpm@linux-foundation.org>
> 
> When dev_name() is changed to return `const char *':
> 
> drivers/net/tokenring/3c359.c: In function 'xl_probe':
> drivers/net/tokenring/3c359.c:318: warning: assignment discards qualifiers from pointer target type
> 
> Cc: Jeff Garzik <jeff@garzik.org>
> Cc: Greg KH <greg@kroah.com>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> ---
> 
>  drivers/net/tokenring/3c359.h |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)

applied


