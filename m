From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next] net: sched: cls_api: make reclassify return
 all the way back to the original tp
Date: Thu, 25 May 2017 12:12:21 -0400 (EDT)
Message-ID: <20170525.121221.927901171298835528.davem@davemloft.net>
References: <20170523071159.1951-1-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jhs@mojatatu.com, xiyou.wangcong@gmail.com,
        dsa@cumulusnetworks.com, edumazet@google.com, daniel@iogearbox.net,
        alexander.h.duyck@intel.com, simon.horman@netronome.com,
        mlxsw@mellanox.com
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:58558 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1034861AbdEYQMX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 25 May 2017 12:12:23 -0400
In-Reply-To: <20170523071159.1951-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Tue, 23 May 2017 09:11:59 +0200

> From: Jiri Pirko <jiri@mellanox.com>
> 
> With the introduction of chain goto action, the reclassification would
> cause the re-iteration of the actual chain. It makes more sense to restart
> the whole thing and re-iterate starting from the original tp - start
> of chain 0.
> 
> Signed-off-by: Jiri Pirko <jiri@mellanox.com>

Applied, thanks Jiri.
