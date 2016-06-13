From: Amir Vadai <amir@vadai.me>
Subject: Re: [PATCH net-next] net/sched: cls_flower: Introduce support in
 SKIP SW flag
Date: Mon, 13 Jun 2016 12:03:55 +0300
Message-ID: <20160613090355.GA30870@office.localdomain>
References: <20160613085812.30742-1-amir@vadai.me>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Jiri Pirko <jiri@mellanox.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	Jakub Kicinski <jakub.kicinski@netronome.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Hadar Har-Zion <hadarh@mellanox.com>,
	Amir Vadai <amirva@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:35470 "EHLO
	mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964873AbcFMJD6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Jun 2016 05:03:58 -0400
Received: by mail-wm0-f65.google.com with SMTP id k184so13129012wme.2
        for <netdev@vger.kernel.org>; Mon, 13 Jun 2016 02:03:57 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20160613085812.30742-1-amir@vadai.me>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jun 13, 2016 at 11:58:12AM +0300, Amir Vadai wrote:
> From: Amir Vadai <amirva@mellanox.com>
> 
> In order to make a filter processed only by hardware, skip_sw flag
> should be supplied. This is an addition to the already existing skip_hw
> flag (filter will be processed by software only). If no flag is
> specified, filter will be processed by both software and hardware.
> 
> If only hardware offloaded filters exist, fl_classify() will return
> without doing anything.
> 
> A following userspace patch will be sent once kernel patch is accepted.
> 
> Example:
> 
> tc filter add dev enp0s9 protocol ip prio 20 parent ffff: \
> 	flower \
> 		ip_proto 6 \
> 		indev enp0s9 \
> 		skip_sw \
> 	action skbedit mark 0x1234
> 
> Signed-off-by: Amir Vadai <amirva@mellanox.com>
> ---

Please ignore this mail - wrong patch sent.

Amir
