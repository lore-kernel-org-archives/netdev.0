From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next 1/3] net: dsa: make the STP state function
 return void
Date: Wed, 6 Apr 2016 01:47:14 +0200
Message-ID: <20160405234714.GB19409@lunn.ch>
References: <1459869875-23815-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Jiri Pirko <jiri@resnulli.us>,
	Scott Feldman <sfeldma@gmail.com>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:48757 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760152AbcDEXrQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Apr 2016 19:47:16 -0400
Content-Disposition: inline
In-Reply-To: <1459869875-23815-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -- port_stp_update: bridge layer function invoked when a given switch port STP
> +- port_stp_state: bridge layer function invoked when a given switch port STP

Hi Vivien

port_stp_state_set might be a better name, to make it clear it is
setting the state, not getting the current state, etc. Most of the
other functions are _add, _prepare, _join, _leave, so _set would fit
the pattern.

Changing to a void makes sense.

	 Andrew
