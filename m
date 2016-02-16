From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [net-next PATCH v2 1/8] net: rework ndo tc op to consume
 additional qdisc handle parameter
Date: Tue, 16 Feb 2016 21:15:50 +0100
Message-ID: <20160216201550.GA2246@nanopsycho.orion>
References: <20160216055819.32452.84181.stgit@john-Precision-Tower-5810>
 <20160216060030.32452.69613.stgit@john-Precision-Tower-5810>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: amir@vadai.me, jhs@mojatatu.com, davem@davemloft.net,
	netdev@vger.kernel.org, jeffrey.t.kirsher@intel.com
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f49.google.com ([74.125.82.49]:33085 "EHLO
	mail-wm0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753879AbcBPUPx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Feb 2016 15:15:53 -0500
Received: by mail-wm0-f49.google.com with SMTP id g62so207953887wme.0
        for <netdev@vger.kernel.org>; Tue, 16 Feb 2016 12:15:52 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20160216060030.32452.69613.stgit@john-Precision-Tower-5810>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tue, Feb 16, 2016 at 07:00:30AM CET, john.fastabend@gmail.com wrote:
>The ndo_setup_tc() op was added to support drivers offloading tx
>qdiscs however only support for mqprio was ever added. So we
>only ever added support for passing the number of traffic classes
>to the driver.
>
>This patch generalizes the ndo_setup_tc op so that a handle can
>be provided to indicate if the offload is for ingress or egress
>or potentially even child qdiscs.
>
>CC: Murali Karicheri <m-karicheri2@ti.com>
>CC: Shradha Shah <sshah@solarflare.com>
>CC: Or Gerlitz <ogerlitz@mellanox.com>
>CC: Ariel Elior <ariel.elior@qlogic.com>
>CC: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
>CC: Bruce Allan <bruce.w.allan@intel.com>
>CC: Jesse Brandeburg <jesse.brandeburg@intel.com>
>CC: Don Skidmore <donald.c.skidmore@intel.com>
>Signed-off-by: John Fastabend <john.r.fastabend@intel.com>

Acked-by: Jiri Pirko <jiri@mellanox.com>
