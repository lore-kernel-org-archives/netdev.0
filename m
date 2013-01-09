From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [patch 3.8-rc2] drivers/net/phy/micrel.c
Date: Wed, 9 Jan 2013 20:54:34 +0000
Message-ID: <1357764874.2654.4.camel@bwh-desktop.uk.solarflarecom.com>
References: <FD9AD8C5375B924CABC56D982DB3A802079D2509@EXMB1.micrel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Doong, Ping" <Ping.Doong@Micrel.Com>
To: "Choi, David" <David.Choi@Micrel.Com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:44564 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933994Ab3AIUyk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Jan 2013 15:54:40 -0500
In-Reply-To: <FD9AD8C5375B924CABC56D982DB3A802079D2509@EXMB1.micrel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

You'll need to give this a proper subject, like 'micrel_phy: Add support
for new PHYs'.

On Wed, 2013-01-09 at 20:09 +0000, Choi, David wrote:
> From: David J. Choi <david.choi@micrel.com>
> 
> Summary of changes:
> This patch is primarily intended to cover more Ethernet phys from Micrel Inc. Additionally it
> .supports ksz8081/91, ksz8061, ksz9051 device.

This is new hardware support which is probably acceptable for the 'net'
tree.

The additional cleanup:

> .changes KSxxx to KSZxxx for unified naming convention. For example, change KS8737 to KSZ8737.
> .changes 9021 to 90x1 for commonly used names between 9021 and 9031 device, as this patch includes 
>  KSZ9031 which belongs to same family as 9021.
[...]

should be a separate patch that goes into the 'net-next' tree.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
