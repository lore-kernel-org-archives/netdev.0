From: Shaaa <shaolinfinest@gmail.com>
Subject: Pseudo-Interface is returning wrong mac address
Date: Fri, 3 Feb 2017 05:56:31 +0000
Message-ID: <CAOfznLKvVVsy7NGiZ3qECZLXgnTmmKahrO3ZbdprvZK4p8s4iw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f169.google.com ([209.85.161.169]:35962 "EHLO
        mail-yw0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752272AbdBCF4d (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 3 Feb 2017 00:56:33 -0500
Received: by mail-yw0-f169.google.com with SMTP id v200so5688613ywc.3
        for <netdev@vger.kernel.org>; Thu, 02 Feb 2017 21:56:32 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I am trying to setup macvlans on a centos7 box. The plan is to have
10.1.1.1/24 on the *main* interface, and then a 10.1.1.10/32 on a
macvlan interface. Output below:

2: ens33: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast
state UP qlen 1000
    link/ether 01:0d:26:9d:cd:16 brd ff:ff:ff:ff:ff:ff
    inet 10.1.1.1/24 brd 10.1.1.1.255 scope global ens33
       valid_lft forever preferred_lft forever
8: peth1@ens33: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc
noqueue state UNKNOWN qlen 1000
    link/ether 02:1a:11:ed:22:ac brd ff:ff:ff:ff:ff:ff
    inet 10.1.1.10/32 scope global peth1
       valid_lft forever preferred_lft forever


The problem is whenever I do arping 10.1.1.10 from another another
host on the network, the mac address of ens33 is returned as opposed
to peth0. I am not entirely sure whether this is intended behaviour or
whether it is a bug, but from what I have gathered, the mac of peth0
should be returned.

I am running the following:
centos 7.3.1611
kernel 3.10.0-514.2.2.el7.x86_64
iproute.x86_64, package version: 3.10.0-74.el7

Please advise.
