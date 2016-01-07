From: Dan Streetman <dan.streetman@canonical.com>
Subject: for stable: xfrm: dst_entries_init() per-net dst_ops
Date: Thu, 7 Jan 2016 17:14:49 -0500
Message-ID: <CAOZ2QJPO4SgWYPA+UpQwhSPAdLwxjtHUQTMZ+05JxmGL1C_v6A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Steffen Klassert <steffen.klassert@secunet.com>,
	Jay Vosburgh <jay.vosburgh@canonical.com>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f179.google.com ([209.85.223.179]:36522 "EHLO
	mail-io0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753224AbcAGWP3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jan 2016 17:15:29 -0500
Received: by mail-io0-f179.google.com with SMTP id g73so70344524ioe.3
        for <netdev@vger.kernel.org>; Thu, 07 Jan 2016 14:15:29 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David, can you queue commit a8a572a for stable please?  It fixes
commit d7c7544c3d from 2010, and without it anyone using multiple
ipsec net namespaces can find one (or more) of their netns incorrectly
reach the ipsec dst limit and are no longer usable.

Thanks!
