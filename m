From: Anand Raj Manickam <anandrm@gmail.com>
Subject: nftables-dports
Date: Wed, 25 Sep 2013 05:48:35 +0530
Message-ID: <CAEyr1FQ4UrXGfdLvT7p=zMTO-C2R1ztogROr7VMo0pQaHGzVfg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qe0-f43.google.com ([209.85.128.43]:64479 "EHLO
	mail-qe0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755323Ab3IYASg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Sep 2013 20:18:36 -0400
Received: by mail-qe0-f43.google.com with SMTP id gh4so3646615qeb.2
        for <netdev@vger.kernel.org>; Tue, 24 Sep 2013 17:18:35 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

How do i add a multiport rule
 nft add rule ip filter output tcp dports 99,200 ip daddr 1.1.1.1
counter meta oif eth0 fails.


I see that the range works,
 nft add rule ip filter output tcp dport 99-105 ip daddr 1.1.1.1
counter meta oif eth0
