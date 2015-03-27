From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH 0/6] mvneta: SGMII-based in-band link state signaling
Date: Fri, 27 Mar 2015 14:39:07 +0100
Message-ID: <20150327133907.GA11975@lunn.ch>
References: <55155AFC.4050800@list.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org,
	Linux kernel <linux-kernel@vger.kernel.org>,
	Stas Sergeev <stsp@users.sourceforge.net>
To: Stas Sergeev <stsp@list.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:58393 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752631AbbC0Nmx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 27 Mar 2015 09:42:53 -0400
Content-Disposition: inline
In-Reply-To: <55155AFC.4050800@list.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 27, 2015 at 04:28:28PM +0300, Stas Sergeev wrote:
> Hello.
> 
> Currently the fixed-link DT binding is pre-configured and
> cannot be changed in run-time. This means the cable unplug
> events are not being detected, and the link parameters can't
> be negotiated.

O.K, i will ask the dumb question....

Isn't fixed-link supposed to be used for links which are fixed?
Why would a fixed-link change?

The use cases i've seen for this is when you are connecting the MAC to
a Switch. The link is configured to its fastest mode and then left
alone.

Please could you give some more background information. What do you
have on the other end of this fixed link which keeps changing?
Obviously not a switch.

Thanks
	Andrew
