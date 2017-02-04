From: Jakub Kicinski <kubakici@wp.pl>
Subject: Re: [PATCH net-next v2 00/12] bnxt_en: Add XDP support.
Date: Fri, 3 Feb 2017 17:41:43 -0800
Message-ID: <20170203174143.016a5a29@cakuba.netronome.com>
References: <1486054540-366-1-git-send-email-michael.chan@broadcom.com>
        <20170203.154910.2213640966872850071.davem@davemloft.net>
        <CACKFLimXCkC1=9kvQnz-s5rjTOGe1gmb9Ozvt1tEeW+O=y7yAg@mail.gmail.com>
        <20170203.165054.437855043325795801.davem@davemloft.net>
        <20170203163003.00d794dc@cakuba.netronome.com>
        <CACKFLikT+o2Uov7Yx3U5zro=cmVasM1Ufa=xxCajDTTV5JeAAA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
        Netdev <netdev@vger.kernel.org>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>
To: Michael Chan <michael.chan@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx4.wp.pl ([212.77.101.12]:9114 "EHLO mx4.wp.pl"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753138AbdBDBmF (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 3 Feb 2017 20:42:05 -0500
In-Reply-To: <CACKFLikT+o2Uov7Yx3U5zro=cmVasM1Ufa=xxCajDTTV5JeAAA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 3 Feb 2017 17:32:16 -0800, Michael Chan wrote:
> On Fri, Feb 3, 2017 at 4:33 PM, Jakub Kicinski <kubakici@wp.pl> wrote:
> > On Fri, 03 Feb 2017 16:50:54 -0500 (EST), David Miller wrote:  
> >> We don't set precedence by one driver saying "hey it's better to do
> >> things this way, forget what all the other drivers are doing."  Rather
> >> we have a "discussion" about what the appropriate thing is to do and
> >> convert all the drivers only after a decision has been made.  
> >
> > Would making sure that if xdp_adjust_head() changes the starting offset
> > (and length) of frame and the program returns XDP_PASS - the stack will
> > see the changes made by xdp_adjust_head() fall under the same follow
> > the precedent rule?  That is what Martin did for mlx4 and mlx5, and what
> > John did in virtio, but not what this patch set does (see my comment on
> > patch 11).
> >
> > I should have double checked mlx4/mlx5 and made it clearer that there is
> > a precedent here in my review comment...  
> 
> Yes, I plan to also include this change (make modified offset and
> length visible to the stack) in the next version of the patch set.

Awesome, thanks!
