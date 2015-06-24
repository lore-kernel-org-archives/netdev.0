From: ratheesh kannoth <ratheesh.ksz@gmail.com>
Subject: sock_hold and sock_put
Date: Wed, 24 Jun 2015 14:47:35 +0530
Message-ID: <CAGZFCEHHXbnsSoBaTUdxqwoQ75hN5BTBXJMEXp0dkwQbFSEkRw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: netdev <netdev@vger.kernel.org>,
	linux-newbie <linux-newbie@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f177.google.com ([209.85.213.177]:36341 "EHLO
	mail-ig0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750933AbbFXJRg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Jun 2015 05:17:36 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi list,

There is a comment on sock_hold() function -

561 /* Grab socket reference count. This operation is valid only
562    when sk is ALREADY grabbed f.e. it is found in hash table
563    or a list and the lookup is made under lock preventing hash table
564    modifications.
565  */


But i could see instances of sock hold() in kernel  without any locks.


How  the race between sock_hold() and sock_put() is prevented in  smp ?

note: I would like to use sock_hold() and sock_put() in
netdev_notifier chain call back functions.

-Ratheesh
