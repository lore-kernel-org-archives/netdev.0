From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH v2 net-next 0/6] Allow bridge to function in non-promisc
 mode
Date: Thu, 2 May 2013 10:23:31 -0700
Message-ID: <20130502102331.43728912@nehalam.linuxnetplumber.net>
References: <1366404770-28523-1-git-send-email-vyasevic@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bridge@lists.linux-foundation.org,
	mst@redhat.com
To: Vlad Yasevich <vyasevic@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:61116 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758632Ab3EBRXr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 May 2013 13:23:47 -0400
Received: by mail-pa0-f53.google.com with SMTP id kq12so472311pab.12
        for <netdev@vger.kernel.org>; Thu, 02 May 2013 10:23:47 -0700 (PDT)
In-Reply-To: <1366404770-28523-1-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Doing research on another problem, I noticed that this would
break user mode spanning tree (RSTP) code.

The daemon assumes that bridge is promicious mode and therefore
will receive all link-level multicast packets.
