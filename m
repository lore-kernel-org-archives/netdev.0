From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: Re: bnx2x null pointer dereference
Date: Sun, 03 Aug 2008 12:36:41 +0300
Message-ID: <1217756201.547.3.camel@lb-tlvb-eliezer>
References: <200807311649.53177.bjorn.helgaas@hp.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Justin Chen" <justin.chen@hp.com>,
	"Bill Hayes" <bill.hayes@hp.com>,
	"Myron Stowe" <myron.stowe@hp.com>
To: "Bjorn Helgaas" <bjorn.helgaas@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:2691 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752783AbYHCJgw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 3 Aug 2008 05:36:52 -0400
In-Reply-To: <200807311649.53177.bjorn.helgaas@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Thu, 2008-07-31 at 15:49 -0700, Bjorn Helgaas wrote:
> The crash below occurred because "params->bp == NULL" in
> bnx2x_update_mng().  This is with the 1.45.11 driver version
> on a RHEL 5.2 kernel.
> 
> This is on a prototype ia64 box, and I'm told that there's
> some bnx2x firmware that is missing from the system firmware,
> so this might be a "we don't care about this problem because
> users will never see this situation" sort of thing.
> 
You are right - the problem is that the data from the board is invalid
since there is no valid boot-code FW burned on it so the board cannot
be used

> But it is annoying that it crashes the box rather than just
> causing the driver to ignore the device.
> 
And this is also true - so we will fix it soon and submit a patch

> Bjorn
> 
Thanks for finding it,
Eilon



