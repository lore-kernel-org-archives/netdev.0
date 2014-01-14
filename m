From: Ian Campbell <Ian.Campbell@citrix.com>
Subject: Re: [Xen-devel] [PATCH net-next v2 3/3] xen-netfront: use new
 skb_checksum_setup function
Date: Tue, 14 Jan 2014 09:33:19 +0000
Message-ID: <1389691999.13654.120.camel@kazak.uk.xensource.com>
References: <1389261768-30606-1-git-send-email-paul.durrant@citrix.com>
	 <1389261768-30606-4-git-send-email-paul.durrant@citrix.com>
	 <20140113.112720.2236966361404094251.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <paul.durrant@citrix.com>, <netdev@vger.kernel.org>,
	<boris.ostrovsky@oracle.com>, <david.vrabel@citrix.com>,
	<xen-devel@lists.xen.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:20615 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750777AbaANJdm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 14 Jan 2014 04:33:42 -0500
In-Reply-To: <20140113.112720.2236966361404094251.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2014-01-13 at 11:27 -0800, David Miller wrote:
> From: Paul Durrant <paul.durrant@citrix.com>
> Date: Thu, 9 Jan 2014 10:02:48 +0000
> 
> > Use skb_checksum_setup to set up partial checksum offsets rather
> > then a private implementation.
> > 
> > Signed-off-by: Paul Durrant <paul.durrant@citrix.com>
> 
> This patch really needs review by a netfront expert before I can apply
> this series.

I think in combination with 1/3 it is basically code motion. So although
I'm not not netfront maintainer:

Acked-by: Ian Campbell <ian.campbell@citrix.com>

Ian.
