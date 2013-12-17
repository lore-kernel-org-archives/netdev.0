From: tedheadster <tedheadster@gmail.com>
Subject: Re: mlx4_en SIOCSHWTSTAMP cycles the link
Date: Tue, 17 Dec 2013 07:06:38 -0500
Message-ID: <CAP8WD_b10d+W8YAtRYW9hGjOkZYq54dJsTiYqocz83tk3zZnRQ@mail.gmail.com>
References: <1386786265-6322-1-git-send-email-shawn.bohrer@gmail.com>
	<20131211185438.GC4371@netboy>
	<20131211212801.GB8283@sbohrermbp13-local.rgmadvisors.com>
	<52A986CF.5030004@mellanox.com>
	<20131212152815.GB3938@sbohrermbp13-local.rgmadvisors.com>
	<20131216233415.GA17259@sbohrermbp13-local.rgmadvisors.com>
	<20131217114455.GC5307@netboy>
Reply-To: whiteheadm@acm.org
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Shawn Bohrer <shawn.bohrer@gmail.com>,
	Hadar Hen Zion <hadarh@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>,
	netdev <netdev@vger.kernel.org>, tomk@rgmadvisors.com,
	Shawn Bohrer <sbohrer@rgmadvisors.com>
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f173.google.com ([209.85.212.173]:60755 "EHLO
	mail-wi0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752778Ab3LQMGj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Dec 2013 07:06:39 -0500
Received: by mail-wi0-f173.google.com with SMTP id hm19so2536188wib.12
        for <netdev@vger.kernel.org>; Tue, 17 Dec 2013 04:06:38 -0800 (PST)
In-Reply-To: <20131217114455.GC5307@netboy>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> After hacking around the SIOCSHWTSTAMP issue I've noticed that ptp4l
> synchronizes the PHC, however there must be another bug somewhere
> because it creates a 35 second offset from the PTP master.

There is an option to ptp4l to account for this. You would use "-O 35"
when starting ptp4, or perhaps '-O -35' (I forget exactly).

- Matthew
