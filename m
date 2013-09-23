From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: iSCSI support in Linux
Date: Mon, 23 Sep 2013 20:04:55 +0100
Message-ID: <1379963095.2485.61.camel@bwh-desktop.uk.level5networks.com>
References: <CAJ3bTp4SRmg78iU-NNF9WtxBdpXc08T+C+j5zPuEVcaxX-H-kA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Rayagond K <rayagond@vayavyalabs.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:46093 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752637Ab3IWTE6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Sep 2013 15:04:58 -0400
In-Reply-To: <CAJ3bTp4SRmg78iU-NNF9WtxBdpXc08T+C+j5zPuEVcaxX-H-kA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2013-09-23 at 16:24 +0530, Rayagond K wrote:
> Hi All,
> 
> I am checking iSCSI support in Linux, during the search over internet
> I got to know that iSCSI standard is implemented in Linux with kernel
> version 2.6.20 and later. But I didn't understand one thing clearly
> that is there any NIC offloading features related iSCSI ? if so, is
> there any support in Linux  for such offloading features ? Any example
> NIC driver in LXR with iSCSI implementation ?

iSCSI drivers are under drivers/scsi not drivers/net.

There's no support for partial offload of iSCSI, beyond TCP offload
features.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
