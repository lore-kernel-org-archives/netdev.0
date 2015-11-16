From: Premkumar Jonnala <pjonnala@broadcom.com>
Subject: RE: [PATCH] bonding: Offloading bonds to hardware
Date: Mon, 16 Nov 2015 06:48:34 +0000
Message-ID: <77EF4405DD4BB54AACCE7DB593DF6A9AA0903F@SJEXCHMB14.corp.ad.broadcom.com>
References: <77EF4405DD4BB54AACCE7DB593DF6A9A9FD653@SJEXCHMB14.corp.ad.broadcom.com>
 <20151114093920.GA2188@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"andrew@lunn.ch" <andrew@lunn.ch>,
	"f.fainelli@gmail.com" <f.fainelli@gmail.com>,
	"idosch@mellanox.com" <idosch@mellanox.com>,
	"nikolay@cumulusnetworks.com" <nikolay@cumulusnetworks.com>,
	"sfeldma@gmail.com" <sfeldma@gmail.com>,
	"gospo@cumulusnetworks.com" <gospo@cumulusnetworks.com>,
	"davem@davemloft.net" <davem@davemloft.net>
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw1-out.broadcom.com ([216.31.210.62]:39136 "EHLO
	mail-gw1-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750889AbbKPGsg convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Nov 2015 01:48:36 -0500
In-Reply-To: <20151114093920.GA2188@nanopsycho.orion>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> 
> Thu, Nov 12, 2015 at 05:02:18PM CET, pjonnala@broadcom.com wrote:
> >Packet forwarding to/from bond interfaces is done in software.
> >
> >This patch enables certain platforms to bridge traffic to/from
> >bond interfaces in hardware.  Notifications are sent out when
> >the "active" slave set for a bond interface is updated in
> >software.  Platforms use the notifications to program the
> >hardware accordingly.  The changes have been verified to work
> >with configured and 802.3ad bond interfaces.
> >
> >Signed-off-by: Premkumar Jonnala <pjonnala@broadcom.com>

Thank you for the comments Jiri.

> This patch is wrong, in many different acpects. Leaving the submission
> style, and no in-tree consumer aside, adding ndos for this thing is
> unacceptable. It should be handled as a part of switchdev attrs.
> Also, the solution should not be bonding-centric.

Can you elaborate on how you envision the solution to be, when you say 
the solution should not be "bonding centric"?

Thanks
Prem

> 
> I have a patchset in my queue which does this correctly, for bond and team
> using switchdev attr and with actual in-tree consumer, mlxsw driver.
> I plan to send that soon after net-next opens.
> 
> Jiri
