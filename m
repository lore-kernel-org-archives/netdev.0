From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH 0/2] inet_diag: Fix old/new inet_diag_req-s structures
Date: Wed, 11 Jan 2012 08:52:50 -0800
Message-ID: <20120111085250.1f40b4d3@nehalam.linuxnetplumber.net>
References: <4F0D49D4.7040100@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Pavel Emelyanov <xemul@parallels.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:52785 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932432Ab2AKQwx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 Jan 2012 11:52:53 -0500
In-Reply-To: <4F0D49D4.7040100@parallels.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 11 Jan 2012 12:35:32 +0400
Pavel Emelyanov <xemul@parallels.com> wrote:

> The recent changes to inet_diag broke the compilation of tools using kernel headers.
> 
> Fix this by doing two sequential renames:
> 
>  inet_diag_req -> inet_diag_req_v2
>  inet_diag_req_compat -> inet_diag_req
> 
> After this the changes in the user-space visible part of the inet_diag.h are
> * add the inet_diag_req_v2
> * extend the INET_DIAG_ extensions list
> 
> The set applies to current net tree.

Tested and build succeeds.

Acked-by: Stephen Hemminger <shemminger@vyatta.com>

Minor nit, it really didn't have to be two patches.
