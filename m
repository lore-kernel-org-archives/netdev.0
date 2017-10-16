From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH] mqprio: Reserve last 32 classid values for HW
 traffic classes and misc IDs
Date: Mon, 16 Oct 2017 20:54:04 +0100 (WEST)
Message-ID: <20171016.205404.135809744834188625.davem@davemloft.net>
References: <20171012182658.14632.9010.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jiri@resnulli.us, amritha.nambiar@intel.com,
        vinicius.gomes@intel.com, netdev@vger.kernel.org, jhs@mojatatu.com,
        jesus.sanchez-palencia@intel.com
To: alexander.duyck@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:34280 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932339AbdJPTyI (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 16 Oct 2017 15:54:08 -0400
In-Reply-To: <20171012182658.14632.9010.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.duyck@gmail.com>
Date: Thu, 12 Oct 2017 11:38:45 -0700

> From: Alexander Duyck <alexander.h.duyck@intel.com>
> 
> This patch makes a slight tweak to mqprio in order to bring the
> classid values used back in line with what is used for mq. The general idea
> is to reserve values :ffe0 - :ffef to identify hardware traffic classes
> normally reported via dev->num_tc. By doing this we can maintain a
> consistent behavior with mq for classid where :1 - :ffdf will represent a
> physical qdisc mapped onto a Tx queue represented by classid - 1, and the
> traffic classes will be mapped onto a known subset of classid values
> reserved for our virtual qdiscs.
> 
> Note I reserved the range from :fff0 - :ffff since this way we might be
> able to reuse these classid values with clsact and ingress which would mean
> that for mq, mqprio, ingress, and clsact we should be able to maintain a
> similar classid layout.
> 
> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>

Applied, thanks Alexander.
