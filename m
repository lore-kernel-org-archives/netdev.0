From: Ian Campbell <Ian.Campbell@citrix.com>
Subject: Re: [Xen-devel] [PATCH 5/6] xen-netback: coalesce slots before
 copying
Date: Tue, 9 Apr 2013 16:10:07 +0100
Message-ID: <1365520207.17014.1.camel@zakaz.uk.xensource.com>
References: <1364209702-12437-1-git-send-email-wei.liu2@citrix.com>
	 <1364209702-12437-6-git-send-email-wei.liu2@citrix.com>
	 <20130325165746.GB25740@phenom.dumpdata.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Wei Liu <wei.liu2@citrix.com>,
	"xen-devel@lists.xen.org" <xen-devel@lists.xen.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"annie.li@oracle.com" <annie.li@oracle.com>,
	David Vrabel <david.vrabel@citrix.com>
To: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.eu.citrix.com ([46.33.159.39]:34521 "EHLO
	SMTP.EU.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760644Ab3DIPKM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Apr 2013 11:10:12 -0400
In-Reply-To: <20130325165746.GB25740@phenom.dumpdata.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2013-03-25 at 16:57 +0000, Konrad Rzeszutek Wilk wrote:
> On Mon, Mar 25, 2013 at 11:08:21AM +0000, Wei Liu wrote:
> > This patch tries to coalesce tx requests when constructing grant copy
> > structures. It enables netback to deal with situation when frontend's
> > MAX_SKB_FRAGS is larger than backend's MAX_SKB_FRAGS.
> >
> > It defines max_skb_slots, which is a estimation of the maximum number of slots
> > a guest can send, anything bigger than that is considered malicious. Now it is
> > set to 20, which should be enough to accommodate Linux (16 to 19).
> >
> > Also change variable name from "frags" to "slots" in netbk_count_requests.
> >
> 
> This should probably also CC stable@vger.kernel.org

DaveM prefers net patches to not do so and he takes care of forwarding
patches once he is happy (i.e. after they've been in his/Linus' tree for
a bit).

Ian
