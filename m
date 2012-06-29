From: Ian Campbell <Ian.Campbell@citrix.com>
Subject: Re: [Xen-devel] [PATCH 1/1] xen/netback: only non-freed SKB is
 queued into tx_queue
Date: Fri, 29 Jun 2012 08:23:09 +0100
Message-ID: <1340954589.5953.12.camel@dagon.hellion.org.uk>
References: <1340794018-17274-1-git-send-email-annie.li@oracle.com>
	 <20120628.165550.1816352825092253548.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "annie.li@oracle.com" <annie.li@oracle.com>,
	"xen-devel@lists.xensource.com" <xen-devel@lists.xensource.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"konrad.wilk@oracle.com" <konrad.wilk@oracle.com>,
	"kurt.hackel@oracle.com" <kurt.hackel@oracle.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.ctxuk.citrix.com ([62.200.22.115]:63333 "EHLO
	SMTP.EU.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751564Ab2F2HXL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Jun 2012 03:23:11 -0400
In-Reply-To: <20120628.165550.1816352825092253548.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2012-06-29 at 00:55 +0100, David Miller wrote:
> From: annie.li@oracle.com
> Date: Wed, 27 Jun 2012 18:46:58 +0800
> 
> > From: Annie Li <Annie.li@oracle.com>
> > 
> > After SKB is queued into tx_queue, it will be freed if request_gop is NULL.
> > However, no dequeue action is called in this situation, it is likely that
> > tx_queue constains freed SKB. This patch should fix this issue, and it is
> > based on 3.5.0-rc4+.
> > 
> > This issue is found through code inspection, no bug is seen with it currently.
> > I run netperf test for several hours, and no network regression was found.
> > 
> > Signed-off-by: Annie Li <annie.li@oracle.com>
> 
> I lack the expertiece necessary to properly review this, so I really
> need a Xen expert to look this over.

Sorry, I put it to one side waiting for the repost to netdev and then
forgot about it...

Yes, this change looks good to me:

Acked-by: Ian Campbell <ian.campbell@citrix.com>
