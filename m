From: "Charles (Chas) Williams" <3chas3@gmail.com>
Subject: [PATCH -stable] virtio-net: drop NETIF_F_FRAGLIST
Date: Tue, 10 Nov 2015 13:26:05 -0500
Message-ID: <1447179965.2645.5.camel@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yk0-f172.google.com ([209.85.160.172]:35960 "EHLO
	mail-yk0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750885AbbKJS0I (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Nov 2015 13:26:08 -0500
Received: by ykdr82 with SMTP id r82so8290078ykd.3
        for <netdev@vger.kernel.org>; Tue, 10 Nov 2015 10:26:07 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dave, could you please add

commit 48900cb6af4282fa0fb6ff4d72a81aa3dadb5c39
virtio-net: drop NETIF_F_FRAGLIST

to your stable queues for 3.14.y and 4.1.y?

This fixes CVE-2015-5156,
https://security-tracker.debian.org/tracker/CVE-2015-5156
