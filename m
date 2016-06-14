From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH] net: smsc911x: If PHY doesn't have an interrupt then POLL
Date: Tue, 14 Jun 2016 20:42:36 +0200
Message-ID: <20160614184236.GB8518@lunn.ch>
References: <1465920962-24946-1-git-send-email-jeremy.linton@arm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, steve.glendinning@shawell.net
To: Jeremy Linton <jeremy.linton@arm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:45645 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932085AbcFNSmj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 14 Jun 2016 14:42:39 -0400
Content-Disposition: inline
In-Reply-To: <1465920962-24946-1-git-send-email-jeremy.linton@arm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 14, 2016 at 11:16:02AM -0500, Jeremy Linton wrote:
> If the interrupt configuration isn't set and we are using the
> internal phy, then we need to poll the phy to reliably detect
> phy state changes.

Hi Jeremy

Why does the external phy not have the exact same problem?

    Andrew
