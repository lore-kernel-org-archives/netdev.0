From: David Miller <davem@davemloft.net>
Subject: Re: getaddrinfo - should accept IPPROTO_SCTP no?
Date: Fri, 13 Oct 2006 15:09:24 -0700 (PDT)
Message-ID: <20061013.150924.104036126.davem@davemloft.net>
References: <45300564.2050504@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:37094
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1751925AbWJMWJX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 13 Oct 2006 18:09:23 -0400
To: rick.jones2@hp.com
In-Reply-To: <45300564.2050504@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Rick Jones <rick.jones2@hp.com>
Date: Fri, 13 Oct 2006 14:30:12 -0700

> I'm about to see about concocting an additional workaround in
> netperf for this, but thought I'd ask if my assumption - that
> getaddrinfo() returning -7 when given IPPROTO_SCTP - is indeed a bug
> in getaddrinfo().  Or am I just woefully behind in patches or
> completely offbase on what is correct behaviour for getaddrinfo and
> hints?

Since getaddrinfo() is implemented in GLIBC, this is not very
much a kernel question unless you can point the failure at
some kernel calls that the GLIBC getaddrinfo() implementation
makes.
