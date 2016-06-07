From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next] net/sched: cls_flower: Introduce support in
 SKIP SW flag
Date: Tue, 7 Jun 2016 14:14:07 +0200
Message-ID: <20160607121407.GB2054@nanopsycho.orion>
References: <20160605141118.10986-1-amir@vadai.me>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Jiri Pirko <jiri@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Hadar Har-Zion <hadarh@mellanox.com>,
	Amir Vadai <amirva@mellanox.com>
To: Amir Vadai <amir@vadai.me>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:35413 "EHLO
	mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753109AbcFGMOL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Jun 2016 08:14:11 -0400
Received: by mail-wm0-f65.google.com with SMTP id k184so17310797wme.2
        for <netdev@vger.kernel.org>; Tue, 07 Jun 2016 05:14:10 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20160605141118.10986-1-amir@vadai.me>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sun, Jun 05, 2016 at 04:11:18PM CEST, amir@vadai.me wrote:
>From: Amir Vadai <amirva@mellanox.com>
>
>In order to make a filter processed only by hardware, skip_sw flag
>should be supplied. This is an addition to the already existing skip_hw
>flag (filter will be processed by software only). If no flag is
>specified, filter will be processed by both software and hardware.
>
>If only hardware offloaded filters exist, fl_classify() will return
>without doing anything.
>
>A following userspace patch will be sent once kernel patch is accepted.
>
>Example:
>
>tc filter add dev enp0s9 protocol ip prio 20 parent ffff: \
>	flower \
>		ip_proto 6 \
>		indev enp0s9 \
>		skip_sw \
>	action skbedit mark 0x1234
>
>Signed-off-by: Amir Vadai <amirva@mellanox.com>
Acked-by: Jiri Pirko <jiri@mellanox.com>
