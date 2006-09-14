From: bora.sahin@ttnet.net.tr
Subject: Re: [PATCH 8/12] smc911x: Fix external phy detect routine
Date: Thu, 14 Sep 2006 12:00:18 +0300
Message-ID: <200609141200.18261.bora.sahin@ttnet.net.tr>
References: <200609132119.18888.bora.sahin@ttnet.net.tr> <20060913190210.GD25007@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="Iso-8859-9"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Dustin McIntire <dustin@sensoria.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.ttnet.net.tr ([212.175.13.129]:7126 "EHLO
	fep04.ttnet.net.tr") by vger.kernel.org with ESMTP id S1751483AbWINI4C
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 Sep 2006 04:56:02 -0400
To: Francois Romieu <romieu@fr.zoreil.com>
In-Reply-To: <20060913190210.GD25007@electric-eye.fr.zoreil.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wednesday 13 September 2006 22:02, Francois Romieu wrote:
> bora.sahin@ttnet.net.tr <bora.sahin@ttnet.net.tr> :
> > 
> > 
> > 9115-an1212.pdf, page 23 -> http://www.smsc.com/main/anpdf/an1212.pdf
> > 
> > "The existence of external PHYs is determined by reading 
> > the same two PHY registers at PHY addresses 0x02 through 0x30. If values of 
> [...]
> > -				for (phyaddr = 1; phyaddr < 32; ++phyaddr) {
> > +				for (phyaddr = 2; phyaddr < 30; ++phyaddr) {
> 
> Is 30 inclusive or not ?

You are right, inclusive...

--
Bora SAHIN 
