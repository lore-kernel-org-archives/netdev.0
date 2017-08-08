From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCHv2 net] net: sched: set xt_tgchk_param par.net properly in
 ipt_init_target
Date: Tue, 8 Aug 2017 07:30:21 +0200
Message-ID: <20170808053021.GB1853@nanopsycho>
References: <5ac3422182618f34f24d0c52cfa8f922ea7c397e.1502158407.git.lucien.xin@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: network dev <netdev@vger.kernel.org>, davem@davemloft.net,
        Cong Wang <xiyou.wangcong@gmail.com>
To: Xin Long <lucien.xin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:37434 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750777AbdHHFaX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 8 Aug 2017 01:30:23 -0400
Received: by mail-wm0-f65.google.com with SMTP id t138so3006380wmt.4
        for <netdev@vger.kernel.org>; Mon, 07 Aug 2017 22:30:23 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <5ac3422182618f34f24d0c52cfa8f922ea7c397e.1502158407.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tue, Aug 08, 2017 at 04:13:27AM CEST, lucien.xin@gmail.com wrote:
>Now xt_tgchk_param par in ipt_init_target is a local varibale,
>par.net is not initialized there. Later when xt_check_target
>calls target's checkentry in which it may access par.net, it
>would cause kernel panic.
>
>Jaroslav found this panic when running:
>
>  # ip link add TestIface type dummy
>  # tc qd add dev TestIface ingress handle ffff:
>  # tc filter add dev TestIface parent ffff: u32 match u32 0 0 \
>    action xt -j CONNMARK --set-mark 4
>
>This patch is to pass net param into ipt_init_target and set
>par.net with it properly in there.
>
>v1->v2:
>  As Wang Cong pointed, I missed ipt_net_id != xt_net_id, so fix
>  it by also passing net_id to __tcf_ipt_init.
>
>Reported-by: Jaroslav Aster <jaster@redhat.com>
>Signed-off-by: Xin Long <lucien.xin@gmail.com>

Fixes what? You need to have "Fixes" tag for net patches.
