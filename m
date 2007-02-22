From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH 2/7] cxgb3 - private ioctl cleanup
Date: Thu, 22 Feb 2007 23:11:24 +0900 (JST)
Message-ID: <20070222.231124.58336645.yoshfuji@linux-ipv6.org>
References: <45DD8DDA.8060303@chelsio.com>
	<20070222.213915.89824941.yoshfuji@linux-ipv6.org>
	<45DD917D.5010807@chelsio.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, swise@opengridcomputing.com,
	yoshfuji@linux-ipv6.org
To: divy@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:57101 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932080AbXBVOLR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Feb 2007 09:11:17 -0500
In-Reply-To: <45DD917D.5010807@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In article <45DD917D.5010807@chelsio.com> (at Thu, 22 Feb 2007 04:50:05 -0800), Divy Le Ray <divy@chelsio.com> says:

> > Even if you remove them, PLEASE DO NOT CHANGE THE VALUES,
> > unless you have very, very good reason.
:
> The cxgb3 driver has not yet appeared in a stable version of the linux 
> kernel.
> The odds of breaking an application using these private ioctls are 
> pretty slim.
> Since some cleanup was required, I chose not to let holes between the 
> values.

Even so, if I were you, I would not have changed them and
I would even try keeping compatibility with old (out-kernel)
drivers.

--yoshfuji
