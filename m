From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [patch net-next 1/4] netdevice: add SW statistics ndo
Date: Sun, 15 May 2016 17:44:11 +0200
Message-ID: <20160515154411.GD9021@lunn.ch>
References: <1463053730-14991-1-git-send-email-jiri@resnulli.us>
 <1463053730-14991-2-git-send-email-jiri@resnulli.us>
 <5734F130.3050303@cumulusnetworks.com>
 <20160513060348.GA2060@nanopsycho.orion>
 <57362154.8040500@cumulusnetworks.com>
 <20160514124917.GA1957@nanopsycho.orion>
 <5737489D.4090800@cumulusnetworks.com>
 <20160514184629.GA2176@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Roopa Prabhu <roopa@cumulusnetworks.com>, netdev@vger.kernel.org,
	davem@davemloft.net, nogahf@mellanox.com, idosch@mellanox.com,
	eladr@mellanox.com, yotamg@mellanox.com, ogerlitz@mellanox.com,
	nikolay@cumulusnetworks.com, linville@tuxdriver.com, tgraf@suug.ch,
	gospo@cumulusnetworks.com, sfeldma@gmail.com, sd@queasysnail.net,
	eranbe@mellanox.com, ast@plumgrid.com, edumazet@google.com,
	hannes@stressinduktion.org
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:38492 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754196AbcEOPoW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 15 May 2016 11:44:22 -0400
Content-Disposition: inline
In-Reply-To: <20160514184629.GA2176@nanopsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> I think we don/t understand each other. HW stats always include SW
> stats. Because whatever goes in or out goes through HW.

Hi Jiri

Bit of a corner case, but what about multicast and broadcast? Can you
do the replication in the switch, so that only a single copy is sent
from the host to the switch?

    Andrew
