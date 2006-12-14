From: Sridhar Samudrala <sri@us.ibm.com>
Subject: Re: [PATCH 4/4][SCTP]: Change adaption -> adaptation as per the
	latest API draft.
Date: Thu, 14 Dec 2006 14:22:16 -0800
Message-ID: <1166134936.13207.30.camel@w-sridhar2.beaverton.ibm.com>
References: <1166042692.4670.13.camel@w-sridhar2.beaverton.ibm.com>
	 <20061213.163554.63998920.davem@davemloft.net>
	 <1166060332.4670.37.camel@w-sridhar2.beaverton.ibm.com>
	 <20061213.180340.26278674.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, lksctp-developers@lists.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e2.ny.us.ibm.com ([32.97.182.142]:41137 "EHLO e2.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S964865AbWLNWWT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 Dec 2006 17:22:19 -0500
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e2.ny.us.ibm.com (8.13.8/8.12.11) with ESMTP id kBEMMIPs006416
	for <netdev@vger.kernel.org>; Thu, 14 Dec 2006 17:22:18 -0500
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay02.pok.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id kBEMMIvZ291656
	for <netdev@vger.kernel.org>; Thu, 14 Dec 2006 17:22:18 -0500
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id kBEMMIQu029993
	for <netdev@vger.kernel.org>; Thu, 14 Dec 2006 17:22:18 -0500
To: David Miller <davem@davemloft.net>
In-Reply-To: <20061213.180340.26278674.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2006-12-13 at 18:03 -0800, David Miller wrote:
> From: Sridhar Samudrala <sri@us.ibm.com>
> Date: Wed, 13 Dec 2006 17:38:52 -0800
> 
> > These parameters are not used by user-space apps. They define the
> > parameters used by the protocol in SCTP headers that go on wire.
> 
> There is no __KERNEL__ ifdef protection for these defines,
> and the linux/sctp.h header is exported to userspace via
> include/linux/Kbuild, therefore the interface is exposed to
> userspace and you cannot break it.

I didn't know that all the files under include/linux are exported
to userspace.
AFAIK, i don't think there are any SCTP apps that use this file.

But if you say that we shouldn't remove any of the APIs in 
linux/sctp.h, i am OK with keeping the existing ones and adding
new ones with the changed name.

Now that 2.6.20-rc1 is out, should i wait until 2.6.21 tree to open
for re-submission or is there a window still open for 2.6.20?

Thanks
Sridhar

