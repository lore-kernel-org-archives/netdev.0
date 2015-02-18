From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH RFC 1/2] net: dsa: integrate with SWITCHDEV for HW
 bridging
Date: Wed, 18 Feb 2015 14:49:37 +0100
Message-ID: <20150218134937.GI10224@lunn.ch>
References: <1424201196-4901-1-git-send-email-f.fainelli@gmail.com>
 <1424201196-4901-2-git-send-email-f.fainelli@gmail.com>
 <20150218011955.GA17155@lunn.ch>
 <54E40CC9.2000505@roeck-us.net>
 <CAGVrzcZNEz6+peBAaSfadFf+wf9p=8EJ0yqBVZqAmnfEaPDFPA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Guenter Roeck <linux@roeck-us.net>,
	netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
	jerome.oufella@savoirfairelinux.com,
	Chris Healy <cphealy@gmail.com>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:45570 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751596AbbBRNw3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 Feb 2015 08:52:29 -0500
Content-Disposition: inline
In-Reply-To: <CAGVrzcZNEz6+peBAaSfadFf+wf9p=8EJ0yqBVZqAmnfEaPDFPA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> I have put a v2 here which addresses that by retaining which bridge
> the port was added to and comparing that against the bridge net_device
> we want to join:
> 
> https://github.com/ffainelli/linux/tree/dsa-hw-bridge-v2

Hi Florian

This looks O.K.

If we ever get a switch which does not allow disjoint sets of ports,
it will need some changes, but lets not over engineer it now.

   Andrew
