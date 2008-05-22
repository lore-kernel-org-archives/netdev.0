From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [patch 07/11] pcnet32: fix warning
Date: Thu, 22 May 2008 06:03:53 -0400
Message-ID: <48354509.9070105@garzik.org>
References: <200805142320.m4ENKEAu026629@imap1.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:44674 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1763355AbYEVKDz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 May 2008 06:03:55 -0400
In-Reply-To: <200805142320.m4ENKEAu026629@imap1.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

akpm@linux-foundation.org wrote:
> From: Andrew Morton <akpm@linux-foundation.org>
> 
> pci_name() will be changed to return `const char *':
> 
> drivers/net/pcnet32.c: In function 'pcnet32_probe1':
> drivers/net/pcnet32.c:1884: warning: passing argument 2 of 'pcnet32_alloc_ring' discards qualifiers from pointer target type
> 
> Cc: Jeff Garzik <jeff@garzik.org>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> ---
> 
>  drivers/net/pcnet32.c |    4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)

applied


