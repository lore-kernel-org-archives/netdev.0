From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next v2 1/1] driver: veth: Refine the statistics
 codes of veth driver
Date: Thu, 03 Nov 2016 08:07:23 -0700
Message-ID: <1478185643.7065.446.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1478178237-23020-1-git-send-email-fgao@ikuai8.com>
         <1478179858.7065.438.camel@edumazet-glaptop3.roam.corp.google.com>
         <CA+6hz4r9zkPp7-mG7b98ocPvjTiheSnEBMjffSkLXD1MM-aMtg@mail.gmail.com>
         <1478183516.7065.440.camel@edumazet-glaptop3.roam.corp.google.com>
         <CA+6hz4owi2WgeGWd98=8d=Q5DBPY4_ZtYAOgcM1V_0+OU8UHrw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
        Cong Wang <cwang@twopensource.com>,
        Vijay Pandurangan <vijayp@vijayp.ca>,
        Evan Jones <ej@evanjones.ca>, pabeni@redhat.com,
        Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Gao Feng <fgao@ikuai8.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:33233 "EHLO
        mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751894AbcKCPHZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 3 Nov 2016 11:07:25 -0400
Received: by mail-pf0-f194.google.com with SMTP id a136so5128249pfa.0
        for <netdev@vger.kernel.org>; Thu, 03 Nov 2016 08:07:25 -0700 (PDT)
In-Reply-To: <CA+6hz4owi2WgeGWd98=8d=Q5DBPY4_ZtYAOgcM1V_0+OU8UHrw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2016-11-03 at 22:38 +0800, Gao Feng wrote:

> Because other net devices put the statistics together.
> Take tun/tap as example, it is a virtual device, but its all
> statistics are percpu including dropped.

Take a look at 2681128f0ced8aa4e66f221197e183cc16d244fe
("veth: reduce stat overhead")

Feel free to fix tun/tap, not bloat veth and undo my work,
without knowing why it was done this way.

Thanks.
