From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: bonding (IEEE 802.3ad) not working with qemu/virtio
Date: Thu, 28 Jan 2016 14:33:50 +0100
Message-ID: <20160128133350.GA2231@nanopsycho.orion>
References: <CAJO99TmB3957Wq3Cse7azgBxKeZ2BV6QihoyAsjUjyvzc-V8dQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>
To: =?iso-8859-1?Q?Bj=F8rnar?= Ness <bjornar.ness@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:35325 "EHLO
	mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750880AbcA1Ndx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Jan 2016 08:33:53 -0500
Received: by mail-wm0-f68.google.com with SMTP id l66so3772731wml.2
        for <netdev@vger.kernel.org>; Thu, 28 Jan 2016 05:33:52 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <CAJO99TmB3957Wq3Cse7azgBxKeZ2BV6QihoyAsjUjyvzc-V8dQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mon, Jan 25, 2016 at 05:24:48PM CET, bjornar.ness@gmail.com wrote:
>As subject says, 802.3ad bonding is not working with virtio network model.
>
>The only errors I see is:
>
>No 802.3ad response from the link partner for any adapters in the bond.
>
>Dumping the network traffic shows that no LACP packets are sent from the
>host running with virtio driver, changing to for example e1000 solves
>this problem
>with no configuration changes.
>
>Is this a known problem?

I believe the problem is virtio_net for obvious reasons does not report
speed and duplex. Bonding 3ad mode makes that unconfortable :)

Use team ;)
