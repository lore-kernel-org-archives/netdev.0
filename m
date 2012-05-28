From: Ian Campbell <Ian.Campbell@citrix.com>
Subject: Re: [PATCH] xen/netback: Calculate the number of SKB slots required
 correctly
Date: Mon, 28 May 2012 09:42:08 +0100
Message-ID: <1338194528.14158.26.camel@zakaz.uk.xensource.com>
References: <1337876767-16041-1-git-send-email-simon.graham@citrix.com>
	 <20120524.162117.2167559109226305167.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Simon Graham <simon.graham@citrix.com>,
	"konrad.wilk@oracle.com" <konrad.wilk@oracle.com>,
	"xen-devel@lists.xensource.com" <xen-devel@lists.xensource.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"bhutchings@solarflare.com" <bhutchings@solarflare.com>,
	"adnan.misherfi@oracle.com" <adnan.misherfi@oracle.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.ctxuk.citrix.com ([62.200.22.115]:8389 "EHLO
	SMTP.EU.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751264Ab2E1ImL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 May 2012 04:42:11 -0400
In-Reply-To: <20120524.162117.2167559109226305167.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-05-24 at 21:21 +0100, David Miller wrote:
> From: Simon Graham <simon.graham@citrix.com>
> Date: Thu, 24 May 2012 12:26:07 -0400
> 
> > When calculating the number of slots required for a packet header, the code
> > was reserving too many slots if the header crossed a page boundary. Since
> > netbk_gop_skb copies the header to the start of the page, the count of
> > slots required for the header should be based solely on the header size.
> > 
> > This problem is easy to reproduce if a VIF is bridged to a USB 3G modem
> > device as the skb->data value always starts near the end of the first page.
> > 
> > Signed-off-by: Simon Graham <simon.graham@citrix.com>
> 
> Applied.

Thanks both!

Ian.
