From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next 1/8] dsa: mv88e6xxx: Prepare for turning this
 into a library module
Date: Thu, 14 Apr 2016 23:37:41 +0200
Message-ID: <20160414213741.GB22846@lunn.ch>
References: <1460591998-20598-1-git-send-email-andrew@lunn.ch>
 <1460591998-20598-2-git-send-email-andrew@lunn.ch>
 <874mb454b3.fsf@ketchup.mtl.sfl>
 <57100B0F.4040909@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:57133 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751449AbcDNVhp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 Apr 2016 17:37:45 -0400
Content-Disposition: inline
In-Reply-To: <57100B0F.4040909@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> I believe this is currently the case for most of what is being done by
> mv88e6xxx.c, Andrew's patches are not making things worse.

Hi Florian

That was my aim. I did the minimum restructuring needed to make these
DSA drivers classical Linux drivers. Nothing i've done would prevent
them being merged into one later. I don't want to do such a merge now,
because that is just a distraction from the bigger picture of
reworking how probe works.

	  Andrew
