From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH v4 0/3] net: dsa: mv88e6xxx: add support for VLAN Table
 Unit
Date: Wed, 8 Jul 2015 22:12:44 +0200
Message-ID: <20150708201244.GE1357@lunn.ch>
References: <1436303900-24259-1-git-send-email-vivien.didelot@savoirfairelinux.com>
 <20150708143805.GA32208@lunn.ch>
 <894793886.88178.1436375596747.JavaMail.zimbra@savoirfairelinux.com>
 <20150708173216.GB1357@lunn.ch>
 <1831874541.91682.1436379099609.JavaMail.zimbra@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>, David <davem@davemloft.net>,
	Scott Feldman <sfeldma@gmail.com>,
	Jiri Pirko <jiri@resnulli.us>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Guenter Roeck <linux@roeck-us.net>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	kernel <kernel@savoirfairelinux.com>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:36532 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758638AbbGHUTD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 8 Jul 2015 16:19:03 -0400
Content-Disposition: inline
In-Reply-To: <1831874541.91682.1436379099609.JavaMail.zimbra@savoirfairelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> I understand. However this whole VLAN thing represents a lot of code.
> Some other work depends on portions of it. Do you think it'd be OK if I
> resend the patch 1/3 alone? Having only the VTU operations and "vtu"
> debugfs file does not break the actual behavior, and will lighten up the
> following patchsets.

It might be a bit early for that. All the previous versions of 1/3
have had issues with number of ports. I've not had time to take a
close look to see if there are other problems.

If somebody else does a proper review and says its O.K, them i'm
O.K. with that. But until that happens, i don't think it should go in.

     Andrew
