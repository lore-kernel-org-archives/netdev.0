From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: [PATCH][BNX2]: Disable MSI on 5706 if AMD 8132 bridge is
 present
Date: Fri, 29 Sep 2006 14:39:23 -0700
Message-ID: <1159565963.3741.23.camel@rh4>
References: <1159564053.3741.19.camel@rh4> <451D9007.6010905@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:26118 "EHLO
	mms2.broadcom.com") by vger.kernel.org with ESMTP id S1422833AbWI2Vm4
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 Sep 2006 17:42:56 -0400
To: "Jeff Garzik" <jeff@garzik.org>
In-Reply-To: <451D9007.6010905@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2006-09-29 at 17:28 -0400, Jeff Garzik wrote:
> Michael Chan wrote:
> > AMD believes this incompatibility is unique to the 5706, and
> > prefers to locally disable MSI rather than globally disabling it
> > using pci_msi_quirk.
> 
> Why is it unique to the 5706?  Is this just a guess on AMD and 
> Broadcom's part?
> 
I just took AMD's word for it.  It doesn't matter to me whether we
disable it locally or globally.  Since this is AMD's bridge, I just
follow their recommendation.  They probably haven't seen this issue on
any other devices except ours.

