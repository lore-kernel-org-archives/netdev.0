From: John Kodis <john.m.kodis@nasa.gov>
Subject: Bad escapes in ip -online
Date: Thu, 7 Sep 2017 12:08:56 -0400
Message-ID: <b4972c84-c827-3a05-2267-bbcadf101260@nasa.gov>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ndgssmtp01.gsfc.nasa.gov ([128.183.245.24]:42309 "EHLO
        ndgssmtp01.ndc.nasa.gov" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1755334AbdIGQPC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 7 Sep 2017 12:15:02 -0400
Received: from tux.gsfc.nasa.gov (tux.gsfc.nasa.gov [128.183.114.23])
        by ndgssmtp01.ndc.nasa.gov (Postfix) with ESMTP id 71B96BB08F9
        for <netdev@vger.kernel.org>; Thu,  7 Sep 2017 11:08:56 -0500 (CDT)
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The -online option to the 'ip link', 'ip addr', and perhaps others is 
putting out a backslash in places where a newline character should go, 
as so:

1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN mode 
DEFAULT group default qlen 1000\    link/loopback 00:00:00:00:00:00 brd 
00:00:00:00:00:00

-- John.
