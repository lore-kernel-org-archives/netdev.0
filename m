From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [net PATCH] mlx4: fix XDP_TX is acting like XDP_PASS on TX ring
 full
Date: Fri, 16 Sep 2016 22:37:59 +0200
Message-ID: <20160916223759.2102a15f@redhat.com>
References: <20160916203535.20016.45146.stgit@firesoul>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>, tom@herbertland.com,
        bblanco@plumgrid.com, rana.shahot@gmail.com,
        "David S. Miller" <davem@davemloft.net>, brouer@redhat.com
To: netdev@vger.kernel.org, tariqt@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:56712 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S965082AbcIPUj1 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 16 Sep 2016 16:39:27 -0400
In-Reply-To: <20160916203535.20016.45146.stgit@firesoul>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 16 Sep 2016 22:36:12 +0200
Jesper Dangaard Brouer <brouer@redhat.com> wrote:

> The XDP_TX action can fail transmitting the frame in case the TX ring
> is full or port is down.  In case of TX failure it should drop the
> frame, and not as now call 'break' which is the same as XDP_PASS.

Ups, forgot to add the V2 subject tag... Dave let me know if I should
resend with V2 in subj.?

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer
