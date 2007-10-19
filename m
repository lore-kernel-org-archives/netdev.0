From: Andrew Morton <akpm@linux-foundation.org>
Subject: networking crash in current mainline: sk_filter_delayed_uncharge()
Date: Thu, 18 Oct 2007 23:09:48 -0700
Message-ID: <20071018230948.959e89d1.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Paul Mackerras <paulus@samba.org>,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:54111 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1761476AbXJSGJz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Oct 2007 02:09:55 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


powerpc mac G5
config: http://userweb.kernel.org/~akpm/config-g5.txt
screenshot: http://userweb.kernel.org/~akpm/dsc00005.jpg

It does this shortly after bringing up eth0 (tg3), in dhclient.

