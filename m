From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next 0/2] Work around missing PHY prodcut ID in
 mv88e6390
Date: Wed, 25 Jan 2017 02:59:05 +0100
Message-ID: <20170125015905.GA24034@lunn.ch>
References: <1485309314-23942-1-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        Gregory Clement <gregory.clement@free-electrons.com>
To: Gregory Clement <gregory.clement@free-electrons.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:44714 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751065AbdAYB7G (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 24 Jan 2017 20:59:06 -0500
Content-Disposition: inline
In-Reply-To: <1485309314-23942-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 25, 2017 at 02:55:12AM +0100, Andrew Lunn wrote:
> The internal PHYs of the MV88E6390 have a Marvell OUI, but the product
> ID is zero. Work around this by trapping reads to the ID, and if it is
> zero, return the MV88E6390 family ID.

Hi Gregory

This should just work for your switch as well, the PHY will get the ID
6390. I expect the PHY is compatible with the 6390 PHYs, so i think we
can just leave it as it is. We can change it later, if we do have
compatibility problems.

	      Andrew
