From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [RFC PATCH 09/16] dsa: dsa: Split up creating/destroying of DSA
 and CPU ports
Date: Fri, 27 May 2016 22:29:34 +0200
Message-ID: <20160527202934.GD23212@lunn.ch>
References: <1464312050-23023-1-git-send-email-andrew@lunn.ch>
 <1464312050-23023-10-git-send-email-andrew@lunn.ch>
 <87bn3rz4jo.fsf@ketchup.mtl.sfl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>,
	Florian Fainelli <f.fainelli@gmail.com>,
	John Crispin <john@phrozen.org>, Bryan.Whitehead@microchip.com
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:53115 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756573AbcE0U3g (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 27 May 2016 16:29:36 -0400
Content-Disposition: inline
In-Reply-To: <87bn3rz4jo.fsf@ketchup.mtl.sfl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> dsa_cpu_dsa_setups is not really meaningful and doesn't add much
> value.

I would disagree.  Quoting Documentation/CodingStyle

                Chapter 6: Functions

Functions should be short and sweet, and do just one thing.  They should
fit on one or two screenfuls of text (the ISO/ANSI screen size is 80x24,
as we all know), and do one thing and do that well.

dsa_cpu_dsa_setups iterates the ports and find the dsa and cpu ports
that need setting up.

dsa_cpu_dsa_setup() does the actual setup.

These are completely different things, and so should be in different
functions.

	Andrew
