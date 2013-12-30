From: Bruno Jesus <00cpxxx@gmail.com>
Subject: IPX socket shutdown() is not implemented
Date: Mon, 30 Dec 2013 13:14:01 -0200
Message-ID: <CALF_nURWWGY68CKUGfw02kLHcy_AwUkPq177uAP6WZ7awMhrgQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f174.google.com ([209.85.213.174]:50369 "EHLO
	mail-ig0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755946Ab3L3PUr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Dec 2013 10:20:47 -0500
Received: by mail-ig0-f174.google.com with SMTP id hk11so35592558igb.1
        for <netdev@vger.kernel.org>; Mon, 30 Dec 2013 07:20:47 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi, as suggested by Alan [1], I'm spreading this in the list hoping
that someone with a better understanding can help solving this issue.
>From bugzilla [2]:

==

With no support to shutdown a parallel (other thread) poll call is not
waken up so applications hang indefinitely while waiting for an
answer.

Still in the latest development version as seen in:
https://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/tree/net/ipx/af_ipx.c?id=refs/tags/v3.13-rc5#n1966

The problem was found while debugging a windows game through wine, the
game is Dune 2000 and the sister bug is
http://bugs.winehq.org/show_bug.cgi?id=6941

==

I understand that IPX is somewhat defunct nowadays but at the same
time by looking in the inet_shutdown function I believe it can be
simple to implement the same for IPX.

[1] https://bugzilla.kernel.org/show_bug.cgi?id=67841#c1
[2] https://bugzilla.kernel.org/show_bug.cgi?id=67841#c0

Best regards,
Bruno
