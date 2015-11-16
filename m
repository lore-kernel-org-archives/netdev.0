From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH] bonding: Offloading bonds to hardware
Date: Mon, 16 Nov 2015 08:46:30 +0100
Message-ID: <20151116074630.GA2217@nanopsycho.orion>
References: <77EF4405DD4BB54AACCE7DB593DF6A9A9FD653@SJEXCHMB14.corp.ad.broadcom.com>
 <20151114093920.GA2188@nanopsycho.orion>
 <77EF4405DD4BB54AACCE7DB593DF6A9AA0903F@SJEXCHMB14.corp.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"andrew@lunn.ch" <andrew@lunn.ch>,
	"f.fainelli@gmail.com" <f.fainelli@gmail.com>,
	"idosch@mellanox.com" <idosch@mellanox.com>,
	"nikolay@cumulusnetworks.com" <nikolay@cumulusnetworks.com>,
	"sfeldma@gmail.com" <sfeldma@gmail.com>,
	"gospo@cumulusnetworks.com" <gospo@cumulusnetworks.com>,
	"davem@davemloft.net" <davem@davemloft.net>
To: Premkumar Jonnala <pjonnala@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f41.google.com ([74.125.82.41]:32779 "EHLO
	mail-wm0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751438AbbKPHqd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Nov 2015 02:46:33 -0500
Received: by wmec201 with SMTP id c201so162060321wme.0
        for <netdev@vger.kernel.org>; Sun, 15 Nov 2015 23:46:32 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <77EF4405DD4BB54AACCE7DB593DF6A9AA0903F@SJEXCHMB14.corp.ad.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mon, Nov 16, 2015 at 07:48:34AM CET, pjonnala@broadcom.com wrote:
>> 
>> Thu, Nov 12, 2015 at 05:02:18PM CET, pjonnala@broadcom.com wrote:
>> >Packet forwarding to/from bond interfaces is done in software.
>> >
>> >This patch enables certain platforms to bridge traffic to/from
>> >bond interfaces in hardware.  Notifications are sent out when
>> >the "active" slave set for a bond interface is updated in
>> >software.  Platforms use the notifications to program the
>> >hardware accordingly.  The changes have been verified to work
>> >with configured and 802.3ad bond interfaces.
>> >
>> >Signed-off-by: Premkumar Jonnala <pjonnala@broadcom.com>
>
>Thank you for the comments Jiri.
>
>> This patch is wrong, in many different acpects. Leaving the submission
>> style, and no in-tree consumer aside, adding ndos for this thing is
>> unacceptable. It should be handled as a part of switchdev attrs.
>> Also, the solution should not be bonding-centric.
>
>Can you elaborate on how you envision the solution to be, when you say 
>the solution should not be "bonding centric"?

You should be able to offload team as well, using the same api.

>
>Thanks
>Prem
>
>> 
>> I have a patchset in my queue which does this correctly, for bond and team
>> using switchdev attr and with actual in-tree consumer, mlxsw driver.
>> I plan to send that soon after net-next opens.
>> 
>> Jiri
