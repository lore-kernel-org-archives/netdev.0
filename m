From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next] bonding: warn user when 802.3ad speed is unknown
Date: Fri, 9 Jun 2017 16:23:59 +0200
Message-ID: <20170609142359.GD20756@lunn.ch>
References: <20170608164811.GB20216@lunn.ch>
 <1497015283-1729-1-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org, j.vosburgh@gmail.com,
        vfalico@gmail.com, andy@greyhouse.net, thibaut.collet@6wind.com,
        linville@tuxdriver.com
To: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:43314 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751527AbdFIOYT (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 9 Jun 2017 10:24:19 -0400
Content-Disposition: inline
In-Reply-To: <1497015283-1729-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jun 09, 2017 at 03:34:43PM +0200, Nicolas Dichtel wrote:
> Make it explicit in the log.
> 
> Suggested-by: Andrew Lunn <andrew@lunn.ch>
> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>

Hi Nicolas

How often is this called? It seems like it is used by
ad_port_selection_logic, which has the comment:

	is called in the inititalization (after all the handshkes),
	and after every lacpdu receive (if selected is off)

I just wonder if this should be rate limited?

  Andrew
