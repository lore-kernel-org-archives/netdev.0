From: Itaru Kitayama <itaru.kitayama@riken.jp>
Subject: System NIC does not get activated at boot time
Date: Thu, 14 Sep 2017 19:41:23 +0900
Message-ID: <d21bdfd4-f660-1958-7ddf-058ab5150ce7@riken.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from postmanrt1.riken.jp ([134.160.33.66]:57898 "EHLO
        postmanrt1.riken.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751500AbdINKu6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 14 Sep 2017 06:50:58 -0400
Received: from postman-ex2.riken.jp (postman-ex2.riken.go.jp [134.160.33.92])
        by postmanrt1.riken.jp (Postfix) with ESMTP id 8FA281E088E
        for <netdev@vger.kernel.org>; Thu, 14 Sep 2017 19:41:25 +0900 (JST)
Received: from postman-ex2.riken.jp (localhost [127.0.0.1])
        by localhost (Postfix) with SMTP id A49426602A8
        for <netdev@vger.kernel.org>; Thu, 14 Sep 2017 19:41:24 +0900 (JST)
Received: from postman.riken.jp (unknown [192.168.60.185])
        by postman-ex2.riken.jp (Postfix) with ESMTP id 932BE66022B
        for <netdev@vger.kernel.org>; Thu, 14 Sep 2017 19:41:24 +0900 (JST)
Received: from postman.riken.jp (localhost.localdomain [127.0.0.1])
        by postman.riken.jp (Postfix) with SMTP id 857DF9413E
        for <netdev@vger.kernel.org>; Thu, 14 Sep 2017 19:41:24 +0900 (JST)
Received: from MacBook-Pro-4.local (anet34.aics.riken.jp [134.160.184.34])
        by postman.riken.jp (Postfix) with ESMTPA id 562899412D
        for <netdev@vger.kernel.org>; Thu, 14 Sep 2017 19:41:24 +0900 (JST)
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Our Cavium ThunderX system's system NIC can not get activated upon boot 
for some reason. To make it active, we need to re-plug the network 
cable. The system is GIGABYTE R150-T62-00 (T45 BIOS), and is powered by 
CentOS 7 (kernel is 4.5.0-25.el7). Has anyone seen this kind of issue on
a ThunderX system?

Itaru
