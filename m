From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH 3/4 net-2.6.26] [SCTP]: seq_printf format warning.
Date: Tue, 04 Mar 2008 02:39:34 +0900 (JST)
Message-ID: <20080304.023934.56690002.yoshfuji@linux-ipv6.org>
References: <1204559323-19953-1-git-send-email-den@openvz.org>
	<1204559323-19953-3-git-send-email-den@openvz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: den@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:53688 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760379AbYCCRic (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Mar 2008 12:38:32 -0500
In-Reply-To: <1204559323-19953-3-git-send-email-den@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In article <1204559323-19953-3-git-send-email-den@openvz.org> (at Mon,  3 Mar 2008 18:48:42 +0300), "Denis V. Lunev" <den@openvz.org> says:

> sctp_association->hbinterval is unsigned long. Replace %8d with %8ld.

Why not %8lu?

--yoshfuji
