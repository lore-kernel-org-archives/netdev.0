From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [patch 0/6] sky2 driver update (v1.11)
Date: Mon, 1 Jan 2007 10:36:44 -0800
Message-ID: <20070101103644.02544c46@freekitty>
References: <20061220210632.183204605@osdl.org>
	<459197B8.6010403@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.25]:50224 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752789AbXABSim (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Jan 2007 13:38:42 -0500
To: Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <459197B8.6010403@pobox.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 26 Dec 2006 16:44:24 -0500
Jeff Garzik <jgarzik@pobox.com> wrote:

> Stephen Hemminger wrote:
> > Patches are in order of severity. 1-3 are bug fixes, 4 is a cleanup
> > of the power state code, and 5 adds wake on lan support.
> > 
> > IMHO, it is bad security policy to allow wake on lan to enabled by default.
> > The sky2 driver doesn't do WOL until enabled with ethtool.
> 
> While in general I agree with you on the security principle, this seems 
> like it might break working setups.
> 
> WOL is a partnership between the motherboard and NIC.  The motherboard 
> must support WOL, or its useless.  And since the motherboard must 
> support WOL, it normally has an on/off switch in BIOS.
> 
> As such, you're overriding the admin's chosen BIOS setting here.
> 
> 	Jeff

But there is no way to read the BIOS settings.

If BIOS was being smart enough to actually, setup the chip, then I can
look at chip registers on startup and see if it is enabled there.


-- 
Stephen Hemminger <shemminger@osdl.org>
