From: Kim Phillips <kim.phillips@freescale.com>
Subject: Re: [PATCH] Add support for running the Marvell m88e1111 PHY in
 RGMII mode
Date: Wed, 11 Apr 2007 16:36:49 -0500
Message-ID: <20070411163649.2d055676.kim.phillips@freescale.com>
References: <20070410165723.472fdc69.kim.phillips@freescale.com>
	<20070411010158.GB9526@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jgarzik@pobox.com
To: Lennert Buytenhek <buytenh@wantstofly.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from de01egw01.freescale.net ([192.88.165.102]:40442 "EHLO
	de01egw01.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965345AbXDKVg4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Apr 2007 17:36:56 -0400
In-Reply-To: <20070411010158.GB9526@xi.wantstofly.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 11 Apr 2007 03:01:58 +0200
Lennert Buytenhek <buytenh@wantstofly.org> wrote:

> On Tue, Apr 10, 2007 at 04:57:23PM -0500, Kim Phillips wrote:
> 
> > also adds RX & TX delay bits to help boards with clock skew
> > problems.
> 
<snip>
> 
> > [...]
> > +
> > +		temp |= (MII_M1111_RX_DELAY | MII_M1111_TX_DELAY);
> 
> Enabling this unconditionally is just wrong.
> 

I agree.  There needs to be a way for the platform code to communicate
board specific quirkiness to the phylib (I just haven't figured out how
to yet).

Kim
