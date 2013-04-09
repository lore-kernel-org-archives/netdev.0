From: Ian Campbell <Ian.Campbell@citrix.com>
Subject: Re: [Xen-devel] [PATCH 1/4] xen-netfront: remove unused variable
 `extra'
Date: Tue, 9 Apr 2013 15:28:04 +0100
Message-ID: <1365517684.10725.42.camel@zakaz.uk.xensource.com>
References: <1363602955-24790-1-git-send-email-wei.liu2@citrix.com>
	 <1363602955-24790-2-git-send-email-wei.liu2@citrix.com>
	 <1363606922.30193.21.camel@zakaz.uk.xensource.com>
	 <1363608271.29093.196.camel@zion.uk.xensource.com>
	 <1363608860.30193.39.camel@zakaz.uk.xensource.com>
	 <5147CFD2.8040803@oracle.com>
	 <291EDFCB1E9E224A99088639C4762022013F7D2D3543@LONPMAILBOX01.citrite.net>
	 <1363706805.3088.6.camel@zion.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Paul Durrant <Paul.Durrant@citrix.com>,
	annie li <annie.li@oracle.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"konrad.wilk@oracle.com" <konrad.wilk@oracle.com>,
	"xen-devel@lists.xen.org" <xen-devel@lists.xen.org>
To: Wei Liu <wei.liu2@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.eu.citrix.com ([46.33.159.39]:29980 "EHLO
	SMTP.EU.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933797Ab3DIO2I (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Apr 2013 10:28:08 -0400
In-Reply-To: <1363706805.3088.6.camel@zion.uk.xensource.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

(apologies for the late reply, I've been away)

On Tue, 2013-03-19 at 15:26 +0000, Wei Liu wrote:
> I think Ian's (and my) idea of redundant is that this 'extra' variable
> is never used in the code now and causes confusion. It can be removed
> now and add back in the future if necessary.

Right, the "extra" I was questioning at the top was a local variable in
the Linux code not the XEN_NETIF_EXTRA_FLAG_MORE thing. Although the
variable was related to the handling of that flag it currently was
written and then never read...

Ian.
