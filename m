From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: [PATCH 2/7] tg3: MII => TP
Date: Sun, 21 Oct 2007 20:49:25 -0700
Message-ID: <1551EAE59135BE47B544934E30FC4FC002AABB03@nt-irva-0751.brcm.ad.broadcom.com>
References: <20071021.161442.22476508.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: netdev@vger.kernel.org, andy@greyhouse.net
To: "David Miller" <davem@davemloft.net>,
	"Matthew Carlson" <mcarlson@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:4623 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751164AbXJVDtf convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 21 Oct 2007 23:49:35 -0400
Content-class: urn:content-classes:message
In-Reply-To: <20071021.161442.22476508.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller wrote:

> From: "Matt Carlson" <mcarlson@broadcom.com>
> Date: Fri, 19 Oct 2007 14:36:42 -0700
> 
> > This patch changes the PHY type reported through ethtool for copper
> > devices from MII to TP.  The latter is more accurate.
> > 
> > Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
> > Signed-off-by: Michael Chan <mchan@broadcom.com>
> 
> You should set both MII and TP, since these copper interfaces
> have a MII based twisted-pair physical layer.
> 
> 

MII in this ethtool context means an MII connector on the card
that can connect to an external transceiver, right?

Or does it mean internal MII interface to the PHY?

