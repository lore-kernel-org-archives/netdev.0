From: David Miller <davem@davemloft.net>
Subject: Re: [take6 0/3] kevent: Generic event handling mechanism.
Date: Wed, 09 Aug 2006 00:58:56 -0700 (PDT)
Message-ID: <20060809.005856.104034268.davem@davemloft.net>
References: <20060731103322.GA1898@2ka.mipt.ru>
	<11551105592821@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, drepper@redhat.com,
	netdev@vger.kernel.org, zach.brown@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:63367
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S965053AbWHIH7H (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 Aug 2006 03:59:07 -0400
To: johnpol@2ka.mipt.ru
In-Reply-To: <11551105592821@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Date: Wed, 9 Aug 2006 12:02:39 +0400

Evgeniy, it's things like the following that make it very draining
mentally to review your work.

>  * removed AIO stuff from patchset

You didn't really do this, you leave the aio_* syscalls and stubs in
there, and you also left things like tcp_async_send() in there.

All the foo_naio_*() stuff is still in there to.

Please remove all of async business we've asked you to.

Thanks.
