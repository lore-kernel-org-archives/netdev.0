From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [RFC 5/9] net: dsa: mv88e6352: disable mirroring
Date: Tue, 2 Jun 2015 16:53:13 +0200
Message-ID: <20150602145313.GU22739@lunn.ch>
References: <1433208470-25338-1-git-send-email-vivien.didelot@savoirfairelinux.com>
 <1433208470-25338-6-git-send-email-vivien.didelot@savoirfairelinux.com>
 <556DBAAA.4010408@roeck-us.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
	netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Scott Feldman <sfeldma@gmail.com>,
	Jiri Pirko <jiri@resnulli.us>,
	Jerome Oufella <jerome.oufella@savoirfairelinux.com>,
	linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
	Chris Healy <cphealy@gmail.com>
To: Guenter Roeck <linux@roeck-us.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:50060 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751691AbbFBO6k (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Jun 2015 10:58:40 -0400
Content-Disposition: inline
In-Reply-To: <556DBAAA.4010408@roeck-us.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 02, 2015 at 07:16:10AM -0700, Guenter Roeck wrote:
> On 06/01/2015 06:27 PM, Vivien Didelot wrote:
> >Disable the mirroring policy in the monitor control register, since this
> >feature is not needed.
> >
> >Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
> 
> Should this be a separate patch, unrelated to the patch set ?
> 
> If I understand correctly, this effectively disables IGMP/MLD snooping.
> I think this warrants an explanation why that it not needed, not just
> a statement that it is not needed.

+1

Especially since we might want to revisit this to implement IGMP/MLD
snooping in the bridge. The hardware should be capable of it.

	 Andrew
