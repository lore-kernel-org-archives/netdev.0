From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH net-next 00/10] bnxt_en: Add XDP support.
Date: Tue, 31 Jan 2017 09:57:33 -0800
Message-ID: <CAADnVQL3s-ebRQyu-a_L7KQuHbXhTrCf3NrnQYP3kQ-Ecmu2SQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Jakub Kicinski <kubakici@wp.pl>,
        David Miller <davem@davemloft.net>,
        Netdev <netdev@vger.kernel.org>
To: Michael Chan <michael.chan@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f41.google.com ([209.85.215.41]:34926 "EHLO
        mail-lf0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752082AbdAaSHP (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 31 Jan 2017 13:07:15 -0500
Received: by mail-lf0-f41.google.com with SMTP id n124so215295675lfd.2
        for <netdev@vger.kernel.org>; Tue, 31 Jan 2017 10:07:09 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 30, 2017 at 11:38 PM, Michael Chan
<michael.chan@broadcom.com> wrote:
>
> I need to first figure out what xdp_adjust_head means.  If it is ok,
> I'd like to defer it.

I'd prefer if it's done asap.

mlx4 support added in
commit ea3349a03519 ("mlx4: xdp: Reserve headroom for receiving packet
when XDP prog is active")

mlx5 support added in
commit d8bec2b29a82 ("net/mlx5e: Support bpf_xdp_adjust_head()")

both were relatively small changes to the driver.
