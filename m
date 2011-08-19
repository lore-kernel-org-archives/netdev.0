From: David Miller <davem@davemloft.net>
Subject: Re: [omega-g1:10937] Re: [PATCH] net: configurable sysctl
 parameter "net.core.tcp_lowat" for sk_stream_min_wspace()
Date: Fri, 19 Aug 2011 02:43:26 -0700 (PDT)
Message-ID: <20110819.024326.598275465899000817.davem@davemloft.net>
References: <4E48B0C3.2010203@ctc-g.co.jp>
	<20110814.224714.2061635645365376268.davem@davemloft.net>
	<4E4E2CCD.6050809@ctc-g.co.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, omega-g1@ctc-g.co.jp,
	notsuki@redhat.com, motokazu.kozaki@hp.com, htaira@redhat.com,
	netdev@vger.kernel.org, tomohiko.takahashi@ctc-g.co.jp,
	kotaro.sakai@ctc-g.co.jp, ken.sugawara@ctc-g.co.jp
To: jun.kondo@ctc-g.co.jp
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:35292 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751896Ab1HSJne (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Aug 2011 05:43:34 -0400
In-Reply-To: <4E4E2CCD.6050809@ctc-g.co.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Jun.Kondo" <jun.kondo@ctc-g.co.jp>
Date: Fri, 19 Aug 2011 18:28:45 +0900

> You suggested to use non-blocking writes, but we think
> we have to rewrite the Apache code if doing so.
> That is, we have to make a modification to Apache that
> depends on the architecture.
> By using this patch, it can be handled by changing the
> configuration a little bit on the kernel side for such
> applications that it is difficult to do so on application
> side.

The kernel provides the facilities necessary to achieve your
goals.  It is a userspace problem.
