From: Zaboj Campula <zaboj.campula@post.cz>
Subject: Re: [PATCH] iproute2: show network device dependency tree
Date: Tue, 28 Feb 2017 20:19:23 +0000
Message-ID: <1488313163.2131.3.camel@post.cz>
References: <20170225165900.10129-1-zaboj.campula@post.cz>
         <20170227105524.64731e21@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mxf2.seznam.cz ([77.75.76.123]:36374 "EHLO mxf2.seznam.cz"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751648AbdB1U5d (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 28 Feb 2017 15:57:33 -0500
In-Reply-To: <20170227105524.64731e21@xeon-e3>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2017-02-27 at 10:55 -0800, Stephen Hemminger wrote:
> 
> Another alternative format would be to make -tree a output modifier and ident (like ps tree options).
> 
> $ ip -t link
> 1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN mode DEFAULT group default qlen 1
>     link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
> 8: bond0 <BROADCAST,MULTICAST> mtu 1500 qdisc pfifo_fast state DOWN mode DEFAULT group default qlen 1000
>     link/ether 52:54:00:66:24:cd brd ff:ff:ff:ff:ff:ff 
>     2: eth1: <BROADCAST,MULTICAST> mtu 1500 qdisc pfifo_fast master bond0 state DOWN mode DEFAULT group default qlen 1000
>         link/ether 52:54:00:66:24:cd brd ff:ff:ff:ff:ff:ff

OK, it looks better because the information is complete.

I looked at several tree printing utilities and I like
the lsblk format. But tabular format does not fit the ip-show
well. I will try to indent the current ip-show output may be
with fancy lines.
