From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: mlx4_en SIOCSHWTSTAMP cycles the link
Date: Tue, 17 Dec 2013 12:44:55 +0100
Message-ID: <20131217114455.GC5307@netboy>
References: <1386786265-6322-1-git-send-email-shawn.bohrer@gmail.com>
 <20131211185438.GC4371@netboy>
 <20131211212801.GB8283@sbohrermbp13-local.rgmadvisors.com>
 <52A986CF.5030004@mellanox.com>
 <20131212152815.GB3938@sbohrermbp13-local.rgmadvisors.com>
 <20131216233415.GA17259@sbohrermbp13-local.rgmadvisors.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Hadar Hen Zion <hadarh@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>, netdev@vger.kernel.org,
	tomk@rgmadvisors.com, Shawn Bohrer <sbohrer@rgmadvisors.com>
To: Shawn Bohrer <shawn.bohrer@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f52.google.com ([74.125.83.52]:47941 "EHLO
	mail-ee0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750929Ab3LQLpB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Dec 2013 06:45:01 -0500
Received: by mail-ee0-f52.google.com with SMTP id d17so2790728eek.25
        for <netdev@vger.kernel.org>; Tue, 17 Dec 2013 03:45:00 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20131216233415.GA17259@sbohrermbp13-local.rgmadvisors.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Dec 16, 2013 at 05:34:15PM -0600, Shawn Bohrer wrote:

> I hacked around this in ptp4l by performing the ioctl once with the
> hwstamp_ctl program from linuxptp and skipping the ioctl in ptp4l,
> which works, but quite frankly this sucks.  I'd love to know if anyone
> has any better ideas on how to make SIOCSHWTSTAMP usable.

So, are you talking about the vlan issue? That would deserve its own
thread.

Thanks,
Richard
