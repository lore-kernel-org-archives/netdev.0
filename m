From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH 1/4] [IPV6]: Fix unbalanced socket reference with
 MSG_CONFIRM.
Date: Thu, 13 Sep 2007 09:35:28 +0900 (JST)
Message-ID: <20070913.093528.54061581.yoshfuji@linux-ipv6.org>
References: <20070913.093039.76110425.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, yoshfuji@linux-ipv6.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:44039 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750856AbXIMAd7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Sep 2007 20:33:59 -0400
In-Reply-To: <20070913.093039.76110425.yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

| [PATCH 1/4] [IPV6]: Fix unbalanced socket reference with MSG_CONFIRM.

Ah, I should say, socket locking, probably...
Anyway, lock_sock() and release_sock() are not paired approriately.

--yoshfuji
