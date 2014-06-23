From: Olaf Hering <olaf@aepfle.de>
Subject: Re: [PATCH net-next] hyperv: Add handler for
 RNDIS_STATUS_NETWORK_CHANGE event
Date: Mon, 23 Jun 2014 18:27:05 +0200
Message-ID: <20140623162705.GA5957@aepfle.de>
References: <1403228076-7596-1-git-send-email-haiyangz@microsoft.com>
 <20140620045704.GA4850@aepfle.de>
 <20140620051213.GA9960@kroah.com>
 <ff458d1b896d4a70a32fa7709911274c@DFM-DB3MBX15-06.exchange.corp.microsoft.com>
 <20140623080242.GA16924@aepfle.de>
 <06b508cbb6b949f4b3e13e7797948e56@DFM-DB3MBX15-06.exchange.corp.microsoft.com>
 <20140623131723.GA7026@aepfle.de>
 <5fb9ddebb68d456ab87979b5cc3830ec@DFM-DB3MBX15-06.exchange.corp.microsoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Greg KH <greg@kroah.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"jasowang@redhat.com" <jasowang@redhat.com>,
	"driverdev-devel@linuxdriverproject.org"
	<driverdev-devel@linuxdriverproject.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>
To: Haiyang Zhang <haiyangz@microsoft.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo4-p00-ob.smtp.rzone.de ([81.169.146.220]:13165 "EHLO
	mo4-p00-ob.smtp.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755600AbaFWQ1J (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Jun 2014 12:27:09 -0400
Content-Disposition: inline
In-Reply-To: <5fb9ddebb68d456ab87979b5cc3830ec@DFM-DB3MBX15-06.exchange.corp.microsoft.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jun 23, Haiyang Zhang wrote:

> I have tried some possibilities, like IF_OPER_DORMANT then IF_OPER_UP with 
> netdev_state_change() etc. but not able to trigger DHCP review. I will look at this
> further...

Is there a link down/up event anyway?
If the interface is configured to "on hotplug" or "on cable plugged in"
or whatever the setting name is, the network scripts should do
something. Even if its not a DHCP renew.

> So, what's the equivalent or similar command to "network restart" on SLES12? Could
> you update the command line for the usermodehelper when porting this patch to SLES
> 12?

I see a /sbin/rcnetwork in SLES, which links either to
'/etc/init.d/network' or 'service'. This could be used as a quick
workaround.

Olaf
