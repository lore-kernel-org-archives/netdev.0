From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH net-next 2/2] net/mlx4_en: Refactor the XDP forwarding
 rings scheme
Date: Sun, 30 Oct 2016 15:44:36 -0700
Message-ID: <20161030224434.GB6658@ast-mbp.hil-sfehihf.abq.wayport.net>
References: <1477579924-32737-1-git-send-email-tariqt@mellanox.com>
 <1477579924-32737-3-git-send-email-tariqt@mellanox.com>
 <20161028010701.GB49550@ast-mbp.thefacebook.com>
 <34ee2e3e-a2ad-2104-9444-ae9c7fed55b7@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Tariq Toukan <tariqt@mellanox.com>,
        "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        Eran Ben Elisha <eranbe@mellanox.com>,
        Brenden Blanco <bblanco@plumgrid.com>
To: Tariq Toukan <ttoukan.linux@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f45.google.com ([209.85.218.45]:32948 "EHLO
        mail-oi0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752796AbcJ3Wqq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 30 Oct 2016 18:46:46 -0400
Received: by mail-oi0-f45.google.com with SMTP id y2so191977745oie.0
        for <netdev@vger.kernel.org>; Sun, 30 Oct 2016 15:46:46 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <34ee2e3e-a2ad-2104-9444-ae9c7fed55b7@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Oct 30, 2016 at 06:03:06PM +0200, Tariq Toukan wrote:
> 
> Note that the XDP TX rings are no longer shown in ethtool -S.

ouch. Can you make it to show them as some large TX numbers instead?
It would really sux to lose stats on them.
