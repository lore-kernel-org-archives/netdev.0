From: Pierre Colombier <pierre@abeille.com>
Subject: feature request for kernel module 8021q
Date: Thu, 14 Sep 2017 21:14:04 +0200
Message-ID: <c010d65d-3050-8d88-22aa-cac092dd3904@abeille.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail3.abeille.com ([212.129.23.178]:38749 "EHLO
        mail3.abeille.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751654AbdINTVQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 14 Sep 2017 15:21:16 -0400
Received: from localhost (localhost [127.0.0.1])
        by mail3.abeille.com (Postfix) with ESMTP id 676E28EC11E2
        for <netdev@vger.kernel.org>; Thu, 14 Sep 2017 21:14:05 +0200 (CEST)
Received: from mail3.abeille.com ([127.0.0.1])
        by localhost (mail3.abeille.com [127.0.0.1]) (amavisd-new, port 10032)
        with ESMTP id Sn8Po0IrWfji for <netdev@vger.kernel.org>;
        Thu, 14 Sep 2017 21:14:05 +0200 (CEST)
Received: from localhost (localhost [127.0.0.1])
        by mail3.abeille.com (Postfix) with ESMTP id EB1F08EC11E0
        for <netdev@vger.kernel.org>; Thu, 14 Sep 2017 21:14:04 +0200 (CEST)
Received: from mail3.abeille.com ([127.0.0.1])
        by localhost (mail3.abeille.com [127.0.0.1]) (amavisd-new, port 10026)
        with ESMTP id SpsJQUlt6Q6J for <netdev@vger.kernel.org>;
        Thu, 14 Sep 2017 21:14:04 +0200 (CEST)
Received: from [192.168.68.20] (pcdwarf.as203500.net [185.178.185.11])
        by mail3.abeille.com (Postfix) with ESMTPSA id C62F48EC11DD
        for <netdev@vger.kernel.org>; Thu, 14 Sep 2017 21:14:04 +0200 (CEST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello


One big problem with vlans on linux is that the native interface always 
get all vlans.

This can cause problem with bridges.


One interesting feature would be to have a special vlan number

(let's say 0 or -1 or 4097 ) designed so that it gets all the untagged 
trafic and only the untagged trafic.

what do you think about this ?
