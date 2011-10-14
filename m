From: Richard Cochran <richardcochran@gmail.com>
Subject: [PATCH net-next 0/1] net: validate HWTSTAMP ioctl parameters
Date: Fri, 14 Oct 2011 11:37:47 +0200
Message-ID: <cover.1318584677.git.richard.cochran@omicron.at>
References: <20110926.160443.1205173553442138535.davem@davemloft.net>
Cc: David Miller <davem@davemloft.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:63268 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752568Ab1JNJho (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Oct 2011 05:37:44 -0400
Received: by bkbzt4 with SMTP id zt4so2589293bkb.19
        for <netdev@vger.kernel.org>; Fri, 14 Oct 2011 02:37:43 -0700 (PDT)
In-Reply-To: <20110926.160443.1205173553442138535.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Okay, here is a patch to check the ioctl.

I took the liberty to check both the Rx and Tx fields. I coded the
check rather pedantically, using a switch/case over the enumerated
values. The advantage of this style is that the compiler will warn
if someone adds a new enum into net_tstamp.h without fixing the
checking function in dev.c.

Richard Cochran (1):
  net: validate HWTSTAMP ioctl parameters

 include/linux/net_tstamp.h |    4 +-
 net/core/dev.c             |   58 ++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 60 insertions(+), 2 deletions(-)

-- 
1.7.2.5
