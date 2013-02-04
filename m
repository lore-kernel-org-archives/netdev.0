From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH v9 net-next 00/12] Add basic VLAN support to bridges
Date: Mon, 4 Feb 2013 08:24:09 -0800
Message-ID: <20130204082409.422ba135@nehalam.linuxnetplumber.net>
References: <1359748930-31475-1-git-send-email-vyasevic@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bridge@lists.linux-foundation.org, davem@davemloft.net,
	netdev@vger.kernel.org
To: Vlad Yasevich <vyasevic@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:39445 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756396Ab3BDQYX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Feb 2013 11:24:23 -0500
Received: by mail-pa0-f50.google.com with SMTP id fa11so867115pad.9
        for <netdev@vger.kernel.org>; Mon, 04 Feb 2013 08:24:22 -0800 (PST)
In-Reply-To: <1359748930-31475-1-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

One thing I am not clear about is whether is supposed to be just
a simple filter of VLAN traffic, or a full VLAN aware bridge.

The change to make FDB entries per-VLAN seems to be the biggest tipping
point into a full VLAN bridge. I am concerned that might break existing
API's and Spanning Tree (internal and external).
