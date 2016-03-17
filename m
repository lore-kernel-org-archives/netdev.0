From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH] net: phy: fix PHY_RUNNING in phy_state_machine
Date: Thu, 17 Mar 2016 16:28:36 +0100
Message-ID: <20160317152836.GE26019@lunn.ch>
References: <1439526220-31458-1-git-send-email-shh.xie@gmail.com>
 <CAGm1_kufFr0SsVwVcABXkL0ABJahiwz4EZ70=ywrtC9Bffbfng@mail.gmail.com>
 <20160316161848.GE2393@lunn.ch>
 <CAGm1_kuMQrECdb6_NpZ83Nm4RFSn6sQMhMK6392PLyaFFxCs1A@mail.gmail.com>
 <20160316230505.GA18161@lunn.ch>
 <CAGm1_kv7eia4LPWT5TxUJp1NV+eFZj6gBQc-pHwxbygoF03EYg@mail.gmail.com>
 <20160317134134.GA24913@lunn.ch>
 <CAGm1_kvJn0Pq38iqOmOcyNpe62EEUmq_s5G2_HXps4Gx+xB_=Q@mail.gmail.com>
 <20160317151240.GD26019@lunn.ch>
 <CAGm1_kt+d7HooYi5JgHvkVYEKO0JLn=1nBgdUd1bSG08+ZLiRg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: shaohui ??? <shh.xie@gmail.com>, netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Shaohui Xie <Shaohui.Xie@freescale.com>,
	Florian Fainelli <f.fainelli@gmail.com>,
	"N, Mugunthan V" <mugunthanvnm@ti.com>, drivshin@allworx.com
To: Yegor Yefremov <yegorslists@googlemail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:49411 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1031459AbcCQP2j (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 Mar 2016 11:28:39 -0400
Content-Disposition: inline
In-Reply-To: <CAGm1_kt+d7HooYi5JgHvkVYEKO0JLn=1nBgdUd1bSG08+ZLiRg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> > You should however consider writing a DSA driver for the switch.
> 
> Do you mean SWITCHDEV or is this more or less the same? From time to
> time I'm looking at DSA/switchdev patches in the mailing list, but
> there seems to be not so many example in kernel. What are the latest
> slides, papers aside from Documentation/networking/switchdev.txt?

I don't have access to the datasheet for this device. So i've no idea
how easy/hard it would be.

Documentation/networking/switchdev.txt and
Documentation/networking/dsa/dsa.txt would be a good place to start.

The mv88e6060.c is the simplest driver and gives you the minimum you
need to start with. Looking at the marketing brief, it looks like the
device can do more. But it is best to start simple, get the minimal
accepted, and then incrementally add more.

	  Andrew
