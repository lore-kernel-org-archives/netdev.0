From: Sriram V <vshrirama@gmail.com>
Subject: Linux raw socket issue
Date: Tue, 14 Feb 2017 16:14:02 +0530
Message-ID: <CAH9_wRO+9rsscYedpKYqTbmHFVLgjqBCOSqD31o-_do6wANT0g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vk0-f42.google.com ([209.85.213.42]:36257 "EHLO
        mail-vk0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750767AbdBNKoE (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 14 Feb 2017 05:44:04 -0500
Received: by mail-vk0-f42.google.com with SMTP id t8so77472497vke.3
        for <netdev@vger.kernel.org>; Tue, 14 Feb 2017 02:44:03 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Apologies if this is not the right mailing list.
I have 2 network interfaces eth0 and eth1. eth0 is the lan and eth1 is the wlan.

I have created a raw socket and bound to eth0 using the below call.

setsockopt(sockfd, SOL_SOCKET, SO_BINDTODEVICE, ifName, strlen(ifName) + 1

I am listening for raw ethernet packets on the eth0. I am getting
packets even if i have removed the
lan cable. I am not sure how the packets from eth1 and sent to eth0?

My program is https://gist.github.com/austinmarton/2862515

I am not sure if there is any IP forwarding causing the issue. There
is a procfs regarding ip forwarding
turning it off or on. does not make any different.


Thanks for your help.

Regards,
Sriram
