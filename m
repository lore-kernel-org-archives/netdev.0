From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH] iproute2: show network device dependency tree
Date: Mon, 27 Feb 2017 10:55:24 -0800
Message-ID: <20170227105524.64731e21@xeon-e3>
References: <20170225165900.10129-1-zaboj.campula@post.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Zaboj Campula <zaboj.campula@post.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f42.google.com ([74.125.83.42]:32874 "EHLO
        mail-pg0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751510AbdB0Sze (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 27 Feb 2017 13:55:34 -0500
Received: by mail-pg0-f42.google.com with SMTP id 25so17951949pgy.0
        for <netdev@vger.kernel.org>; Mon, 27 Feb 2017 10:55:31 -0800 (PST)
In-Reply-To: <20170225165900.10129-1-zaboj.campula@post.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 25 Feb 2017 16:59:00 +0000
Zaboj Campula <zaboj.campula@post.cz> wrote:

> Add the argument '-tree' to ip-link to show network devices dependency tree.
> 
> Example:
> 
> $ ip -tree link
> eth0
>     bond0
> eth1
>     bond0
> eth2
>     bond1
> eth3
>     bond1

Another alternative format would be to make -tree a output modifier and ident (like ps tree options).

$ ip -t link
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN mode DEFAULT group default qlen 1
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
8: bond0 <BROADCAST,MULTICAST> mtu 1500 qdisc pfifo_fast state DOWN mode DEFAULT group default qlen 1000
    link/ether 52:54:00:66:24:cd brd ff:ff:ff:ff:ff:ff 
    2: eth1: <BROADCAST,MULTICAST> mtu 1500 qdisc pfifo_fast master bond0 state DOWN mode DEFAULT group default qlen 1000
        link/ether 52:54:00:66:24:cd brd ff:ff:ff:ff:ff:ff
