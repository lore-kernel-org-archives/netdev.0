From: David Miller <davem@davemloft.net>
Subject: Re: [omega-g1:11110] Re: [PATCH] net: configurable sysctl
 parameter "net.core.tcp_lowat" for sk_stream_min_wspace()
Date: Thu, 08 Sep 2011 22:17:46 -0400 (EDT)
Message-ID: <20110908.221746.534664053184784881.davem@davemloft.net>
References: <4E55D3C2.40308@ctc-g.co.jp>
	<20110824.220016.781758659534965980.davem@davemloft.net>
	<4E696D06.3000003@ctc-g.co.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, omega-g1@ctc-g.co.jp,
	notsuki@redhat.com, motokazu.kozaki@hp.com, htaira@redhat.com,
	netdev@vger.kernel.org, tomohiko.takahashi@ctc-g.co.jp,
	kotaro.sakai@ctc-g.co.jp, ken.sugawara@ctc-g.co.jp
To: jun.kondo@ctc-g.co.jp
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:33960 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932548Ab1IICSG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Sep 2011 22:18:06 -0400
In-Reply-To: <4E696D06.3000003@ctc-g.co.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Jun.Kondo" <jun.kondo@ctc-g.co.jp>
Date: Fri, 09 Sep 2011 10:33:58 +0900

> - In normal situation, acquire large default transmission
>   buffer value, and ensure high throughput from the
>   beginning of tcp connection

You should never do this.  You should use the default buffer sizes and
as a result the kernel's TCP stack automatically adjusts the send and
receive buffers in response to the link characteristics.

When you set explicit buffer sizes, this turns off the TCP stack's
auto-tuning mechanism.

Every argument made in support of your proposed feature is based upon
a false premise of one kind of another, and this is yet another example
of this.
