From: Yang Hongyang <yanghy@cn.fujitsu.com>
Subject: get receiving interface index while no message is received
Date: Fri, 08 Aug 2008 12:27:06 +0800
Message-ID: <489BCB1A.5040100@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:50706 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1750815AbYHHE1m (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 8 Aug 2008 00:27:42 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


when I use getsockopt(sk, IPPROTO_IPV6, IPV6_2292PKTOPTIONS,(char *)incmsg, &cnt)
to get receiving interface index while no message is received,

What interface index should be returned?
