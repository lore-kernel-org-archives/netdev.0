From: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
Subject: Re: [PATCH v1 08/12] IB/cma: Add net_dev and private data checks to
 RDMA CM
Date: Thu, 16 Jul 2015 12:22:20 -0600
Message-ID: <20150716182220.GE3680@obsidianresearch.com>
References: <1434976961-27424-1-git-send-email-haggaie@mellanox.com>
 <1434976961-27424-9-git-send-email-haggaie@mellanox.com>
 <20150713181414.GJ23832@obsidianresearch.com>
 <55A63CAC.60603@mellanox.com>
 <20150715184934.GD23588@obsidianresearch.com>
 <HE1PR05MB1418C82958B3CCF0D3531E5BB19A0@HE1PR05MB1418.eurprd05.prod.outlook.com>
 <20150715210342.GA32516@obsidianresearch.com>
 <HE1PR05MB1418FA1E41CFA446C04FC07FB1990@HE1PR05MB1418.eurprd05.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Haggai Eran <haggaie@mellanox.com>,
	Doug Ledford <dledford@redhat.com>,
	"linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Guy Shapiro <guysh@mellanox.com>,
	Shachar Raindel <raindel@mellanox.com>,
	Yotam Kenneth <yotamke@mellanox.com>
To: Liran Liss <liranl@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from quartz.orcorp.ca ([184.70.90.242]:58962 "EHLO quartz.orcorp.ca"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756206AbbGPSWX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 16 Jul 2015 14:22:23 -0400
Content-Disposition: inline
In-Reply-To: <HE1PR05MB1418FA1E41CFA446C04FC07FB1990@HE1PR05MB1418.eurprd05.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jul 16, 2015 at 12:01:55PM +0000, Liran Liss wrote:

> - Name space lookup is done based on BTH.pkey, private_data.IP, and
>   optionally GRH.DGID (if present, for extra validation)

Just changing the pkey to BTH.pkey would be fine by me.

Using GRH.DGID if available instead of the primary path hack is also
smart, I pointed that out at the beginning..

Jason
