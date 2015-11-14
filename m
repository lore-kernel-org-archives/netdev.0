From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH] bonding: Offloading bonds to hardware
Date: Sat, 14 Nov 2015 10:40:47 +0100
Message-ID: <20151114094047.GA2218@nanopsycho.orion>
References: <77EF4405DD4BB54AACCE7DB593DF6A9A9FD653@SJEXCHMB14.corp.ad.broadcom.com>
 <20151112170801.GG20177@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Premkumar Jonnala <pjonnala@broadcom.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f46.google.com ([74.125.82.46]:35476 "EHLO
	mail-wm0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751111AbbKNJkt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 Nov 2015 04:40:49 -0500
Received: by wmdw130 with SMTP id w130so56643303wmd.0
        for <netdev@vger.kernel.org>; Sat, 14 Nov 2015 01:40:48 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20151112170801.GG20177@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thu, Nov 12, 2015 at 06:08:01PM CET, andrew@lunn.ch wrote:
>On Thu, Nov 12, 2015 at 04:02:18PM +0000, Premkumar Jonnala wrote:
>> Packet forwarding to/from bond interfaces is done in software.
>> 
>> This patch enables certain platforms to bridge traffic to/from
>> bond interfaces in hardware.  Notifications are sent out when 
>> the "active" slave set for a bond interface is updated in 
>> software.  Platforms use the notifications to program the 
>> hardware accordingly.  The changes have been verified to work 
>> with configured and 802.3ad bond interfaces.
>
>Hi Premkumar
>
>Nice to see this. Do you also have patches for a switch using these
>notification? Are you targeting Starfighter 2?

I fear they are targeting some closed-source crap :/
