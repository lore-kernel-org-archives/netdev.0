From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [net-next PATCH v3 1/8] net: rework ndo tc op to consume
 additional qdisc handle parameter
Date: Wed, 17 Feb 2016 05:42:48 -0500
Message-ID: <56C44EA8.8050801@mojatatu.com>
References: <20160217051418.17139.41052.stgit@john-Precision-Tower-5810>
 <20160217051615.17139.95379.stgit@john-Precision-Tower-5810>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeffrey.t.kirsher@intel.com
To: John Fastabend <john.fastabend@gmail.com>, jiri@resnulli.us,
	amir@vadai.me, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f174.google.com ([209.85.213.174]:37929 "EHLO
	mail-ig0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1161083AbcBQKmv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Feb 2016 05:42:51 -0500
Received: by mail-ig0-f174.google.com with SMTP id y8so12021333igp.1
        for <netdev@vger.kernel.org>; Wed, 17 Feb 2016 02:42:51 -0800 (PST)
In-Reply-To: <20160217051615.17139.95379.stgit@john-Precision-Tower-5810>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-02-17 12:16 AM, John Fastabend wrote:
> The ndo_setup_tc() op was added to support drivers offloading tx
> qdiscs however only support for mqprio was ever added. So we
> only ever added support for passing the number of traffic classes
> to the driver.
>
> This patch generalizes the ndo_setup_tc op so that a handle can
> be provided to indicate if the offload is for ingress or egress
> or potentially even child qdiscs.
>
> CC: Murali Karicheri <m-karicheri2@ti.com>
> CC: Shradha Shah <sshah@solarflare.com>
> CC: Or Gerlitz <ogerlitz@mellanox.com>
> CC: Ariel Elior <ariel.elior@qlogic.com>
> CC: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> CC: Bruce Allan <bruce.w.allan@intel.com>
> CC: Jesse Brandeburg <jesse.brandeburg@intel.com>
> CC: Don Skidmore <donald.c.skidmore@intel.com>
> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
> Acked-by: Jiri Pirko <jiri@mellanox.com>

Acked-by: Jamal Hadi Salim <jhs@mojatatu.com>
