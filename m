From: =?utf-8?B?0JDQu9C10LrRgdC10Lkg0JHQvtC70LTRi9GA0LXQsg==?=
        <devel-net-ne-vlezay80@yandex.ru>
Subject: Maximum MPLS labels on Linux network stack
Date: Wed, 03 May 2017 20:33:07 +0300
Message-ID: <149211493832787@web33j.yandex.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from forward20o.cmail.yandex.net ([37.9.109.219]:40801 "EHLO
        forward20o.cmail.yandex.net" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1754135AbdECRkj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 3 May 2017 13:40:39 -0400
Received: from mxback6j.mail.yandex.net (mxback6j.mail.yandex.net [IPv6:2a02:6b8:0:1619::10f])
        by forward20o.cmail.yandex.net (Yandex) with ESMTP id D464622DE2
        for <netdev@vger.kernel.org>; Wed,  3 May 2017 20:33:08 +0300 (MSK)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I watched one forum, there is listed in the properties of one license for Cisco, it says:

Layer 3 VPN • Multi-VRF CE (VRF-lite); requires IP Services Feature license
• MPLS VPN; requires Advanced IP Feature license
• 26 VRFs
• 8192 MPLS labels 

Especially interested in the figure 8192 MPLS Labels.

As I understand it, is it either a limit on the number of labels on the stack or the total number of labels?

In Linux, for example, you can specify a common col- lection of labels through /proc/sys/net/mpls/platforms_labels

Also I would like to know if the openvswitch has a limit of 3 tags in the stack or the total number of MPLS labels that can send?
