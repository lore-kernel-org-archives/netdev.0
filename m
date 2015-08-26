From: Sowmini Varadhan <sowmini05@gmail.com>
Subject: Re: [PATCH RFC 0/5] net: L2 only interfaces
Date: Tue, 25 Aug 2015 17:05:46 -0700
Message-ID: <CACP96tRLeuNo3vqWxLXSbcevVsr+b6AR_VfbxrOQ78tCtiTB1Q@mail.gmail.com>
References: <1440543015-14693-1-git-send-email-f.fainelli@gmail.com>
	<CACP96tSxYyWUhAeXTzc49P4Wk3Lr6mr1MMm_7pZQoK4iEdQ5sg@mail.gmail.com>
	<55DCFFB2.1030100@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Florian Fainelli <f.fainelli@gmail.com>,
	netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>, andrew@lunn.ch,
	linux@roeck-us.net,
	=?UTF-8?B?SmnFmcOtIFDDrXJrbw==?= <jiri@resnulli.us>,
	sfeldma@gmail.com
To: David Ahern <dsa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f176.google.com ([209.85.223.176]:35005 "EHLO
	mail-io0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755480AbbHZAFq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Aug 2015 20:05:46 -0400
Received: by iodt126 with SMTP id t126so15024iod.2
        for <netdev@vger.kernel.org>; Tue, 25 Aug 2015 17:05:46 -0700 (PDT)
In-Reply-To: <55DCFFB2.1030100@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 25, 2015 at 4:52 PM, David Ahern <dsa@cumulusnetworks.com> wrote:


> The VRF driver can check the device when the enslave request happens.
>

Will this work correctly if I set up a bonding interface or SVI,
and want to put the bond-master or SVI in the vrf (but subsequently
want to get, say, timestamp/other-stats from the L2 slave in the vrf?)

--Sowmini
