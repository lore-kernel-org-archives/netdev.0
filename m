From: Dan Streetman <ddstreet@ieee.org>
Subject: for stable: xfrm: dst_entries_init() per-net dst_ops
Date: Mon, 25 Jan 2016 12:36:57 -0500
Message-ID: <CALZtONBA3hi_Gj5uAzTc6Wb-2Tk5NqVDPRkC=FLxj3G=_bdrzg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org,
	Steffen Klassert <steffen.klassert@secunet.com>,
	Dan Streetman <dan.streetman@canonical.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f50.google.com ([209.85.218.50]:33888 "EHLO
	mail-oi0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964806AbcAYRhi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Jan 2016 12:37:38 -0500
Received: by mail-oi0-f50.google.com with SMTP id k206so93179657oia.1
        for <netdev@vger.kernel.org>; Mon, 25 Jan 2016 09:37:37 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David, can you queue commit a8a572a for stable please?  It fixes
commit d7c7544c3d from 2010, and without it anyone using multiple
ipsec net namespaces can find one (or more) of their netns incorrectly
reach the ipsec dst limit and are no longer usable.

Thanks!
