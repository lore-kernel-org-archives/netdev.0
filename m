From: Wei Liu <wei.liu2@citrix.com>
Subject: Re: [PATCH net-next 2/4] xen-netback: add control protocol
 implementation
Date: Tue, 10 May 2016 14:29:18 +0100
Message-ID: <20160510132918.GD12241@citrix.com>
References: <1462447170-1815-1-git-send-email-paul.durrant@citrix.com>
 <1462447170-1815-3-git-send-email-paul.durrant@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <xen-devel@lists.xenproject.org>, <netdev@vger.kernel.org>,
	Wei Liu <wei.liu2@citrix.com>
To: Paul Durrant <paul.durrant@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:29674 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751229AbcEJN3Z (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 May 2016 09:29:25 -0400
Content-Disposition: inline
In-Reply-To: <1462447170-1815-3-git-send-email-paul.durrant@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 05, 2016 at 12:19:28PM +0100, Paul Durrant wrote:
> My recent patch to include/xen/interface/io/netif.h defines a new shared
> ring (in addition to the rx and tx rings) for passing control messages
> from a VM frontend driver to a backend driver.
> 
> A previous patch added the necessary boilerplate for mapping the control
> ring from the frontend, should it be created. This patch adds
> implementations for each of the defined protocol messages.
> 
> Signed-off-by: Paul Durrant <paul.durrant@citrix.com>
> Cc: Wei Liu <wei.liu2@citrix.com>
> ---
>  drivers/net/xen-netback/Makefile    |   2 +-
>  drivers/net/xen-netback/common.h    |  43 +++++
>  drivers/net/xen-netback/hash.c      | 361 ++++++++++++++++++++++++++++++++++++
>  drivers/net/xen-netback/interface.c |  28 +++
>  drivers/net/xen-netback/netback.c   |  49 ++++-
>  5 files changed, 480 insertions(+), 3 deletions(-)
>  create mode 100644 drivers/net/xen-netback/hash.c
> 

Other than the issue mentioned by David, the code looks OK to me.

Wei.
