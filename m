From: Naveen <dear.chap@gmail.com>
Subject: Fwd: Delivery Status Notification (Failure)
Date: Thu, 24 Sep 2015 08:03:39 -0400
Message-ID: <CAOLDph0pO0q3A4-mRjn3wkGvHP5c9anBWbaDBDOLhVRz+JVDMQ@mail.gmail.com>
References: <047d7b5dbb76a0065405207cfe24@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f44.google.com ([209.85.218.44]:33301 "EHLO
	mail-oi0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754122AbbIXMDk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Sep 2015 08:03:40 -0400
Received: by oixx17 with SMTP id x17so39821058oix.0
        for <netdev@vger.kernel.org>; Thu, 24 Sep 2015 05:03:40 -0700 (PDT)
In-Reply-To: <047d7b5dbb76a0065405207cfe24@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi
     Right now the only way to detect if an interface has a peer(veth)
is touse ethtool -S. Instead I was thinking of adding it to device
attributes as a peer_ifndex entry. In drivers/net/veth.c I could add
an entry to
dev->groups for a veth specific group. Would that be acceptable ?

Thanks
Naveen
