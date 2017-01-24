From: Simon Horman <simon.horman@netronome.com>
Subject: Re: [patch net-next v2 2/4] net/sched: Introduce sample tc action
Date: Tue, 24 Jan 2017 09:33:19 +0100
Message-ID: <20170124083318.GB25022@penelope.horms.nl>
References: <1485166031-4773-1-git-send-email-jiri@resnulli.us>
 <1485166031-4773-3-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, yotamg@mellanox.com,
        idosch@mellanox.com, eladr@mellanox.com, nogahf@mellanox.com,
        ogerlitz@mellanox.com, jhs@mojatatu.com, geert+renesas@glider.be,
        stephen@networkplumber.org, xiyou.wangcong@gmail.com,
        linux@roeck-us.net, roopa@cumulusnetworks.com,
        john.fastabend@gmail.com, mrv@mojatatu.com
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f46.google.com ([74.125.82.46]:38414 "EHLO
        mail-wm0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750811AbdAXId2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 24 Jan 2017 03:33:28 -0500
Received: by mail-wm0-f46.google.com with SMTP id r144so196182567wme.1
        for <netdev@vger.kernel.org>; Tue, 24 Jan 2017 00:33:27 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1485166031-4773-3-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 23, 2017 at 11:07:09AM +0100, Jiri Pirko wrote:
> From: Yotam Gigi <yotamg@mellanox.com>
> 
> This action allows the user to sample traffic matched by tc classifier.
> The sampling consists of choosing packets randomly and sampling them using
> the psample module. The user can configure the psample group number, the
> sampling rate and the packet's truncation (to save kernel-user traffic).
> 
> Example:
> To sample ingress traffic from interface eth1, one may use the commands:
> 
> tc qdisc add dev eth1 handle ffff: ingress
> 
> tc filter add dev eth1 parent ffff: \
> 	   matchall action sample rate 12 group 4
> 
> Where the first command adds an ingress qdisc and the second starts
> sampling randomly with an average of one sampled packet per 12 packets on
> dev eth1 to psample group 4.
> 
> Signed-off-by: Yotam Gigi <yotamg@mellanox.com>
> Signed-off-by: Jiri Pirko <jiri@mellanox.com>
> Acked-by: Jamal Hadi Salim <jhs@mojatatu.com>

Reviewed-by: Simon Horman <simon.horman@netronome.com>

Is the tc user-space (iproute2) code available yet?
