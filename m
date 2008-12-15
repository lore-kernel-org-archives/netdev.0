From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: Re: bnx2x machine check in bnx2x_ack_int()
Date: Mon, 15 Dec 2008 19:18:00 +0200
Message-ID: <1229361480.22295.22.camel@lb-tlvb-eliezer>
References: <200812091204.35296.bjorn.helgaas@hp.com>
 <1229328209.22295.16.camel@lb-tlvb-eliezer>
 <200812150921.08668.bjorn.helgaas@hp.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Bjorn Helgaas" <bjorn.helgaas@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:1904 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753164AbYLORTu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 15 Dec 2008 12:19:50 -0500
In-Reply-To: <200812150921.08668.bjorn.helgaas@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2008-12-15 at 08:21 -0800, Bjorn Helgaas wrote:

> > > I'm using bnx2x 1.45.23 from RHEL5.3s4 on a prototype ia64 platform,
> > > and I see intermittent machine checks at bnx2x_ack_int+176, which is
> > > just after __ia64_readl() returns.
> > I see that you are using two 57710 chips. What kind of board are you
> > using (which PHY)?
> 
> This is a blade with separate PHYs.  In this case, there is no PHY
> at all because the module that would contain the PHY is not installed.
> 
> > > This is a proto with incomplete firmware, and the driver correctly
> > > complains about that, but it seems like there's still a hole where
> > > things blow up.
> > If you set the right FW on the board, do you still see the problem? I'm
> > asking to determine if this is a problem specific to the "no FW" case or
> > general issue with this configuration
> 
> I'm trying to get FW installed, but haven't had any luck yet.

Hmmm... So it is possible that this is HW related (since we are talking
about preliminary board with missing component and missing FW). I will
ask for some field support - someone will contact you shortly.

Thanks,
Eilon


