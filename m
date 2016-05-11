From: Wei Liu <wei.liu2@citrix.com>
Subject: Re: [PATCH net-next v3 1/4] xen-netback: add control ring boilerplate
Date: Wed, 11 May 2016 17:02:44 +0100
Message-ID: <20160511160244.GG8063@citrix.com>
References: <1462980817-10149-1-git-send-email-paul.durrant@citrix.com>
 <1462980817-10149-2-git-send-email-paul.durrant@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <xen-devel@lists.xenproject.org>, <netdev@vger.kernel.org>,
	Wei Liu <wei.liu2@citrix.com>
To: Paul Durrant <paul.durrant@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:37872 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932174AbcEKQCq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 May 2016 12:02:46 -0400
Content-Disposition: inline
In-Reply-To: <1462980817-10149-2-git-send-email-paul.durrant@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, May 11, 2016 at 04:33:34PM +0100, Paul Durrant wrote:
> My recent patch to include/xen/interface/io/netif.h defines a new shared
> ring (in addition to the rx and tx rings) for passing control messages
> from a VM frontend driver to a backend driver.
> 
> This patch adds the necessary code to xen-netback to map this new shared
> ring, should it be created by a frontend, but does not add implementations
> for any of the defined protocol messages. These are added in a subsequent
> patch for clarity.
> 
> Signed-off-by: Paul Durrant <paul.durrant@citrix.com>

Acked-by: Wei Liu <wei.liu2@citrix.com>
