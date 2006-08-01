From: David Miller <davem@davemloft.net>
Subject: Re: [RFC 1/4] kevent: core files.
Date: Tue, 01 Aug 2006 00:58:09 -0700 (PDT)
Message-ID: <20060801.005809.102616533.davem@davemloft.net>
References: <20060731.035716.39159213.davem@davemloft.net>
	<20060731105943.GA26114@gondor.apana.org.au>
	<44CF0866.3000505@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, johnpol@2ka.mipt.ru,
	zach.brown@oracle.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:19081
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1422769AbWHAH6v (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Aug 2006 03:58:51 -0400
To: drepper@redhat.com
In-Reply-To: <44CF0866.3000505@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ulrich Drepper <drepper@redhat.com>
Date: Tue, 01 Aug 2006 00:53:10 -0700

> This is the case to keep in mind here.  I thought Zach and the other
> involved in the discussions in Ottawa said this has been shown to be a
> problem and that a ring buffer implementation with something other than
> simple front and back pointers is preferable.

This is part of why I suggested VJ style channel data
structure.  At worst, the cachelines for the entries get
into shared modified state when the remove userland cpu
reads the slot.
