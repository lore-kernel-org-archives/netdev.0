From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH] net/bridge: Add 'hairpin' port forwarding mode
Date: Thu, 13 Aug 2009 19:06:21 +0200
Message-ID: <200908131906.21916.arnd@arndb.de>
References: <0199E0D51A61344794750DC57738F58E6D6B0C70D9@GVW1118EXC.americas.hpqcorp.net>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	"Paul Congdon (UC Davis)" <ptcongdon@ucdavis.edu>,
	"evb@yahoogroups.com" <evb@yahoogroups.com>,
	"bridge@lists.linux-foundation.org"
	<bridge@lists.linux-foundation.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"virtualization@lists.linux-foundation.org"
	<virtualization@lists.linux-foundation.org>,
	"kaber@trash.net" <kaber@trash.net>,
	"Dickson, Mike (ISS Software)" <mike.dickson@hp.com>,
	"adobriyan@gmail.com" <adobriyan@gmail.com>,
	"bridge@osdl.org" <bridge@osdl.org>
To: "Fischer, Anna" <anna.fischer@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.177]:52231 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752291AbZHMRHh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Aug 2009 13:07:37 -0400
In-Reply-To: <0199E0D51A61344794750DC57738F58E6D6B0C70D9@GVW1118EXC.americas.hpqcorp.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thursday 13 August 2009, Fischer, Anna wrote:
> This patch adds a 'hairpin' (also called 'reflective relay') mode
> port configuration to the Linux Ethernet bridge kernel module.
> A bridge supporting hairpin forwarding mode can send frames back
> out through the port the frame was received on.
> 
> Hairpin mode is required to support basic VEPA (Virtual
> Ethernet Port Aggregator) capabilities.
> 
> You can find additional information on VEPA here:
> http://tech.groups.yahoo.com/group/evb/
> http://www.ieee802.org/1/files/public/docs2009/new-hudson-vepa_seminar-20090514d.pdf
> http://www.internet2.edu/presentations/jt2009jul/20090719-congdon.pdf
> 
> An additional patch 'bridge-utils: Add 'hairpin' port forwarding mode'
> is provided to allow configuring hairpin mode from userspace tools.
> 
> Signed-off-by: Paul Congdon <paul.congdon@hp.com>
> Signed-off-by: Anna Fischer <anna.fischer@hp.com>

Acked-by: Arnd Bergmann <arnd@arndb.de>
