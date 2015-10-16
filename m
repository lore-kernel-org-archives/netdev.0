From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH net-next 0/9] netlink: strict attribute checking
 option
Date: Fri, 16 Oct 2015 01:06:44 -0700 (PDT)
Message-ID: <20151016.010644.2090038835491896678.davem@davemloft.net>
References: <cover.1444926905.git.jbenc@redhat.com>
	<20151015.235007.973370825335101214.davem@davemloft.net>
	<20151016093945.54a6a7aa@griffin>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tgraf@suug.ch
To: jbenc@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51988 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753894AbbJPHuf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Oct 2015 03:50:35 -0400
In-Reply-To: <20151016093945.54a6a7aa@griffin>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Benc <jbenc@redhat.com>
Date: Fri, 16 Oct 2015 09:39:45 +0200

> I'm targeting net-next only and don't intend to bring this to older
> kernels. The patchset is designed in the way that it's possible to
> detect that the kernel does not support strict attribute checking. When
> this is detected, the tools will just assume that lwtunnel support is
> not there.

No, it's definitely not OK, because lwtunnel support exists in
Linus's tree.

And tools should be able to work on all kernels where lwtunnel support
is available.
