From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [RFC PATCH 09/16] dsa: dsa: Split up creating/destroying of DSA
 and CPU ports
Date: Fri, 27 May 2016 22:01:46 +0200
Message-ID: <20160527200146.GA23212@lunn.ch>
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
Received: from vps0.lunn.ch ([178.209.37.122]:53094 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750744AbcE0UBt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 27 May 2016 16:01:49 -0400
Content-Disposition: inline
In-Reply-To: <87bn3rz4jo.fsf@ketchup.mtl.sfl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, May 27, 2016 at 03:25:47PM -0400, Vivien Didelot wrote:
> Hi Andrew, Florian,
> 
> I suggest to use this RFC to agree on a consistent and robust API for
> the DSA layer. Some functions have non-intuitive names or signatures.

Nope.

What is important is getting this patchset accepted and merged, so
people can write drivers using it.

Changes like this can come later, since hopefully all changes like
this are internal. They don't affect the drivers, or the API to the
core.

	Andrew
