From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [net PATCH V3] mlx4: fix XDP_TX is acting like XDP_PASS on TX
 ring full
Date: Mon, 19 Sep 2016 09:42:19 +0200
Message-ID: <20160919094219.5b0d11cd@redhat.com>
References: <20160917164650.53e68314@redhat.com>
        <20160917154753.3130.16986.stgit@firesoul>
        <20160919.013925.1660395475687226712.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tariqt@mellanox.com, tom@herbertland.com,
        bblanco@plumgrid.com, rana.shahot@gmail.com, brouer@redhat.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:36214 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1760428AbcISHmZ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 19 Sep 2016 03:42:25 -0400
In-Reply-To: <20160919.013925.1660395475687226712.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 19 Sep 2016 01:39:25 -0400 (EDT)
David Miller <davem@davemloft.net> wrote:

> From: Jesper Dangaard Brouer <brouer@redhat.com>
> Date: Sat, 17 Sep 2016 17:48:00 +0200
> 
> > The XDP_TX action can fail transmitting the frame in case the TX ring
> > is full or port is down.  In case of TX failure it should drop the
> > frame, and not as now call 'break' which is the same as XDP_PASS.
> > 
> > Fixes: 9ecc2d86171a ("net/mlx4_en: add xdp forwarding and data write support")
> > Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>  
> 
> Oops, I applied v2 of this patch.  Please send me any necessary
> relative fixups, thanks.

Okay, I just send the needed fix up in/with:

Subj: [net-next PATCH] mlx4: add missed recycle opportunity for XDP_TX on TX failure

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer
