From: "Wyborny, Carolyn" <carolyn.wyborny@intel.com>
Subject: RE: bonding + igb TX queue warnings
Date: Mon, 14 Feb 2011 10:55:52 -0800
Message-ID: <EDC0E76513226749BFBC9C3FB031318F012FB5EEBC@orsmsx508.amr.corp.intel.com>
References: <20110202155556.GA5127@linuxace.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: Phil Oester <kernel@linuxace.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:56110 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751865Ab1BNSzx convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Feb 2011 13:55:53 -0500
In-Reply-To: <20110202155556.GA5127@linuxace.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



>-----Original Message-----
>From: netdev-owner@vger.kernel.org [mailto:netdev-owner@vger.kernel.org]
>On Behalf Of Phil Oester
>Sent: Wednesday, February 02, 2011 7:56 AM
>To: netdev@vger.kernel.org
>Subject: bonding + igb TX queue warnings
>
>Running 2.6.36.3 here, and brought up a bond on 2 igb interfaces.
>Syslog now getting flooded with this:
>
>kernel: bond0 selects TX queue 16, but real number of TX queues is 16
>
>Any way to change which queue bond0 is selecting or otherwise fix
>this?
>
>Phil
>--
>To unsubscribe from this list: send the line "unsubscribe netdev" in
>the body of a message to majordomo@vger.kernel.org
>More majordomo info at  http://vger.kernel.org/majordomo-info.html

Hello,

I apologize for the delay in responding.  This looks like a bonding problem where the queue count isn't starting from zero as expected.  This part has 16 queues, but the highest queue selection would be 15, not 16.

Thanks,

Carolyn

Carolyn Wyborny
Linux Development
LAN Access Division
Intel Corporation



