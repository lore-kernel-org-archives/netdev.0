From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: RE: [PATCH v4 net-next 01/10] qed: Add module with basic common
 support
Date: Sat, 10 Oct 2015 14:18:18 +0000
Message-ID: <B5657A6538887040AD3A81F1008BEC63E44712@avmb3.qlogic.org>
References: <1444217127-17557-1-git-send-email-Yuval.Mintz@qlogic.com>
	<1444217127-17557-2-git-send-email-Yuval.Mintz@qlogic.com>,<20151010.062452.1106942695684145823.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: netdev <netdev@vger.kernel.org>,
	Ariel Elior <Ariel.Elior@qlogic.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:18737 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751397AbbJJOSX convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 10 Oct 2015 10:18:23 -0400
In-Reply-To: <20151010.062452.1106942695684145823.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> > +config QED
> > +     tristate "QLogic QED 25/40/100Gb core driver"
> > +     depends on PCI && X86_64
> > +     ---help---
> > +       This enables the support for ...

> You should be maximizing the number of platforms that can at least
> build test this driver, rather than restricting things so much.

> If you are making this restriction because there are x86_64'isms
> in this driver, that's even worse.

> So I want to see this depending upon "PCI" only.

So far we've worked on stabalizing it on 64-bit LE endian.
I can easily understand why we'd want to relax this restriction later on
[and sooner rather than later], but what would you gain be gained by
compile-fixing for platforms on which it was never tested?