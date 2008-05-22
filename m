From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [patch 09/11] drivers/net/tokenring/olympic.c: fix warning
Date: Thu, 22 May 2008 06:04:06 -0400
Message-ID: <48354516.8060004@garzik.org>
References: <200805142320.m4ENKGSF026635@imap1.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, greg@kroah.com
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:44687 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1764120AbYEVKEI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 May 2008 06:04:08 -0400
In-Reply-To: <200805142320.m4ENKGSF026635@imap1.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

akpm@linux-foundation.org wrote:
> From: Andrew Morton <akpm@linux-foundation.org>
> 
> When dev_name() is changed to return `const char *':
> 
> drivers/net/tokenring/olympic.c: In function 'olympic_probe':
> drivers/net/tokenring/olympic.c:234: warning: assignment discards qualifiers from pointer target type
> 
> Cc: Jeff Garzik <jeff@garzik.org>
> Cc: Greg KH <greg@kroah.com>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> ---
> 
>  drivers/net/tokenring/olympic.h |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)

applied


