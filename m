From: Andrew Goodbody <andrew.goodbody@cambrionix.com>
Subject: RE: [PATCH v2 0/1] drivers: net: cpsw: Fix NULL pointer dereference
 with two slave PHYs
Date: Wed, 20 Apr 2016 08:49:34 +0000
Message-ID: <c10cbc575f4d4e15bd27a8018f77baf1@THHSTE15D2BE2.hs20.net>
References: <1460987606-18125-1-git-send-email-andrew.goodbody@cambrionix.com>
 <20160419.201550.902520333910307559.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"David Rivshin (Allworx)" <drivshin.allworx@gmail.com>,
	"grygorii.strashko@ti.com" <grygorii.strashko@ti.com>,
	"mugunthanvnm@ti.com" <mugunthanvnm@ti.com>,
	"linux-omap@vger.kernel.org" <linux-omap@vger.kernel.org>,
	"tony@atomide.com" <tony@atomide.com>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160419.201550.902520333910307559.davem@davemloft.net>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> -----Original Message-----
> From: Andrew Goodbody <andrew.goodbody@cambrionix.com>
> Date: Mon, 18 Apr 2016 14:53:25 +0100
> 
> > This is a fix for a NULL pointer dereference from cpsw which is
> > triggered by having two slave PHYs attached to a cpsw network device.
> > The problem is due to only maintaining a single reference to a PHY
> > node in the prive data which gets overwritten by the second PHY probe.
> > So move the PHY node reference to the individual slave data so that there
> is now one per slave.
> >
> > v1 had a problem that data->slaves was used before it had been filled
> > in
> 
> I already applied v1 the other day, so you need to send me a relative patch
> rather than a whole new one.
> 
> Thanks.

Sorry, I had no notification that this had happened. However I thought that the plan was to revert v1 and go with David Rivshin's patch instead. I'll see if I can create a revert in a little while.

Andrew
