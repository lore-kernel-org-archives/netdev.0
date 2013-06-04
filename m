From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [BUG] acess_ok() missing from zerocopy_sg_from_iovec()
Date: Mon, 03 Jun 2013 17:34:12 -0700
Message-ID: <1370306052.24311.193.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f180.google.com ([209.85.192.180]:54355 "EHLO
	mail-pd0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754821Ab3FDAeN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Jun 2013 20:34:13 -0400
Received: by mail-pd0-f180.google.com with SMTP id 14so6347157pdc.25
        for <netdev@vger.kernel.org>; Mon, 03 Jun 2013 17:34:13 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It looks like access_ok(VERIFY_READ, base, len) checks are missing in
drivers/net/tun.c & drivers/net/macvtap.c before the
get_user_pages_fast() calls.

Or am I missing something ?
