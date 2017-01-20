From: Valentine Sinitsyn <valentine.sinitsyn@gmail.com>
Subject: ipv6_get_ifaddr() not exported
Date: Fri, 20 Jan 2017 13:55:52 +0500
Message-ID: <d5305aae-20ed-d5cf-78a7-414b49075223@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f49.google.com ([209.85.215.49]:36007 "EHLO
        mail-lf0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751512AbdATIzz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 20 Jan 2017 03:55:55 -0500
Received: by mail-lf0-f49.google.com with SMTP id z134so53034680lff.3
        for <netdev@vger.kernel.org>; Fri, 20 Jan 2017 00:55:55 -0800 (PST)
Received: from ?IPv6:2a02:6b8:0:2807:cde1:8c1:2576:7afc? ([2a02:6b8:0:2807:cde1:8c1:2576:7afc])
        by smtp.googlemail.com with ESMTPSA id f133sm3059451lfg.32.2017.01.20.00.55.53
        for <netdev@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 20 Jan 2017 00:55:53 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all,

I'm working on a custom Netfilter module which could seemingly use 
ipv6_get_ifaddr() function to find a netdev which has a destination IPv6 
assigned (if any). The function is public, but not exported, so I can't 
use it in my module.

Am I doing anything wrong, or I'm just a first type to use 
ipv6_get_ifaddr() outside net/ipv6 code, and it's okay to export it now?

Thanks,
Valentine
