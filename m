From: Yegor Yefremov <yegorslists@googlemail.com>
Subject: KS8695: possible NAPI issue
Date: Tue, 2 Mar 2010 13:04:20 +0100
Message-ID: <f69abfc31003020404y7af77fe5icefeee4644c7d08e@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: figo1802@gmail.com, zealcook@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f220.google.com ([209.85.219.220]:44924 "EHLO
	mail-ew0-f220.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752181Ab0CBMEZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Mar 2010 07:04:25 -0500
Received: by ewy20 with SMTP id 20so79773ewy.21
        for <netdev@vger.kernel.org>; Tue, 02 Mar 2010 04:04:24 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I'm using 2.6.33 kernel and I noticed such a strange behavior:

after system start I transfer one file via netcat from my development
host, after this transfer the network is not functioning i.e. no pings
possible etc.

To narrow down the problem I checked out this commit
http://git.kernel.org/?p=linux/kernel/git/torvalds/linux-2.6.git;a=commit;h=451f14439847db302e5104c44458b2dbb4b1829d.
Till here the network driver is functioning as intended, but after
NAPI introduction I have this issue. With latest git-pull of "Linus'
kernel tree" I can't even ping right after the systems start.

Any Ideas? What am I missing?

Regards,
Yegor
