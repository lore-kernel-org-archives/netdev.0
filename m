From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Subject: Re: bnx2x null pointer dereference
Date: Mon, 4 Aug 2008 09:18:19 -0600
Message-ID: <200808040918.19550.bjorn.helgaas@hp.com>
References: <200807311649.53177.bjorn.helgaas@hp.com> <1217756201.547.3.camel@lb-tlvb-eliezer>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Justin Chen" <justin.chen@hp.com>,
	"Bill Hayes" <bill.hayes@hp.com>,
	"Myron Stowe" <myron.stowe@hp.com>
To: "Eilon Greenstein" <eilong@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0029.austin.hp.com ([15.216.28.36]:40270 "EHLO
	g1t0029.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753238AbYHDPSg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Aug 2008 11:18:36 -0400
In-Reply-To: <1217756201.547.3.camel@lb-tlvb-eliezer>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sunday 03 August 2008 03:36:41 am Eilon Greenstein wrote:
> 
> On Thu, 2008-07-31 at 15:49 -0700, Bjorn Helgaas wrote:
> > The crash below occurred because "params->bp == NULL" in
> > bnx2x_update_mng().  This is with the 1.45.11 driver version
> > on a RHEL 5.2 kernel.
> > 
> > This is on a prototype ia64 box, and I'm told that there's
> > some bnx2x firmware that is missing from the system firmware,
> > so this might be a "we don't care about this problem because
> > users will never see this situation" sort of thing.
> > 
> You are right - the problem is that the data from the board is invalid
> since there is no valid boot-code FW burned on it so the board cannot
> be used
> 
> > But it is annoying that it crashes the box rather than just
> > causing the driver to ignore the device.
> > 
> And this is also true - so we will fix it soon and submit a patch

Great!  Thanks for looking into this.  I'd be glad to help test
the patch when it's ready.

Bjorn
