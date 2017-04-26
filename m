From: Michael Ma <make0818@gmail.com>
Subject: Multiple Txqs with One Qdisc
Date: Tue, 25 Apr 2017 21:46:41 -0700
Message-ID: <CAAmHdhyA+JZrdFcwsWAzQOcSA6EUbWu4h5YcOA0vc2y01ZEBkg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: Linux Kernel Network Developers <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f48.google.com ([209.85.218.48]:35585 "EHLO
        mail-oi0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1430728AbdDZEqn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 26 Apr 2017 00:46:43 -0400
Received: by mail-oi0-f48.google.com with SMTP id j201so196005759oih.2
        for <netdev@vger.kernel.org>; Tue, 25 Apr 2017 21:46:42 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi -

As I mentioned in a previous thread, we're implementing a qdisc
similar to mqprio which can associate multiple txqs to one qdisc, so
that we can work around the root qdisc bottleneck. I think this should
be in general fine since without MQ, root qdisc is associated with
multiple txqs anyway. However we encountered kernel panic as I
mentioned in the "corrupted skb" thread.

Any thought on potential issue of doing this? I'm asking this because
mqprio only associates one txq with one qdisc which I think must have
been done this way for a reason.

Would appreciate if anyone can shed some light on this.

Thanks,
Michael
