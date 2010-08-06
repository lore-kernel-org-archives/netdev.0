From: Ben Hutchings <bhutchings@solarflare.com>
Subject: RE: [PATCH] virtio_net: implements ethtool_ops.get_drvinfo
Date: Fri, 06 Aug 2010 17:15:51 +0100
Message-ID: <1281111351.2088.7.camel@achroite.uk.solarflarecom.com>
References: <201008051302.06045.rusty@rustcorp.com.au>
	 <1280980041.13192.628.camel@localhost>
	 <D3F292ADF945FB49B35E96C94C2061B90C96F8B5@nsmail.netscout.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Rusty Russell <rusty@rustcorp.com.au>, netdev@vger.kernel.org,
	"Michael S. Tsirkin" <mst@redhat.com>,
	Taku Izumi <izumi.taku@jp.fujitsu.com>
To: "Loke, Chetan" <Chetan.Loke@netscout.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:28910 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755937Ab0HFQPz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Aug 2010 12:15:55 -0400
In-Reply-To: <D3F292ADF945FB49B35E96C94C2061B90C96F8B5@nsmail.netscout.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2010-08-06 at 11:59 -0400, Loke, Chetan wrote:
> > This information is already available generically through sysfs:
> >     basename $(readlink /sys/class/net/eth3/device)
> >     basename $(readlink /sys/class/net/eth3/device/driver)
> > 
> > Given that, we should either recommend that people use that method
> > instead
> 
> sysfs-rules.txt::"Accessing /sys/class/net/eth0/device is a bug in the application."
> 
> I understand Dave has accepted the patch already(which is perfect).
> I'm not being sarcastic but I really want to understand if I can
> access these nodes.

You should probably believe that document rather than me.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

