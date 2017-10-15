From: =?utf-8?B?0JzQuNGF0LDQuNC7INCd0L7QstC+0YHQtdC70L7Qsiwg0KjQrdCcINCU0YPQvNCw0LvQvtCz0LjRjw==?=
        <mikhailnov@dumalogiya.ru>
Subject: [REGRESSION] rtl8723bs (r8723bs) WiFi stopped working on 4.14 on Chuwi Hi12 (Intel CherryTrail SoC)
Date: Sun, 15 Oct 2017 16:37:40 +0300
Message-ID: <2750281508074660@web27g.yandex.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from forward101p.mail.yandex.net ([77.88.28.101]:52140 "EHLO
        forward101p.mail.yandex.net" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751096AbdJONpX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 15 Oct 2017 09:45:23 -0400
Received: from mxback4o.mail.yandex.net (mxback4o.mail.yandex.net [IPv6:2a02:6b8:0:1a2d::1e])
        by forward101p.mail.yandex.net (Yandex) with ESMTP id 06FB86A823C0
        for <netdev@vger.kernel.org>; Sun, 15 Oct 2017 16:37:41 +0300 (MSK)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,
I've found a regression in kernel 4.14, the last tested kernel was the yesterday daily build http://kernel.ubuntu.com/~kernel-ppa/mainline/daily/ , it worked on 4.12 and 4.13 and now on 4.14 it is able to scan for available networks, but is not able to get an IP adress.
I reported a bug to the kernel's bugzilla: https://bugzilla.kernel.org/show_bug.cgi?id=197137 
---------------------------------------------------------------------------------

Hardware platform: Chuwi Hi12 (intell cherrytrail tablet)
On Linux kernels 4.12 and 4.13 the WiFi does work, starting from 4.14 not release builds it does not, including some dily builds of the times somewhere near rc1, the rc3 release and the letest daily build of the code state for 2017-10-04 http://kernel.ubuntu.com/~kernel-ppa/mainline/daily/2017-10-05/ 
I will provide logs from 4.14 a bit later, bellow are LOGS FROM 4.13.1 with working WiFi

Full information on hardware and logs (including full dmesg) are here: https://linux-hardware.org/index.php?probe=01521aa6cf (kernel 4.13 and working wifi)

$ dmesg | grep rtl
[    7.899105] RTL8723BS: rtl8723bs v4.3.5.5_12290.20140916_BTCOEX20140507-4E40
[    7.899106] RTL8723BS: rtl8723bs BT-Coex version = BTCOEX20140507-4E40
[   10.570755] rtl8723bs: acquire FW from file:rtlwifi/rtl8723bs_nic.bin

Logs from 4.14 with WiFi not working: https://linux-hardware.org/index.php?probe=5c7b00c4cb
