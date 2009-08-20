From: "Steinar H. Gunderson" <sgunderson@bigfoot.com>
Subject: IPV6_RTHDR with a type-0 routing header
Date: Thu, 20 Aug 2009 13:11:52 +0200
Message-ID: <20090820111152.GA20295@uio.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org, shanwei@cn.fujitsu.com
To: brian.haley@hp.com, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from cassarossa.samfundet.no ([129.241.93.19]:41090 "EHLO
	cassarossa.samfundet.no" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752723AbZHTLL6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Aug 2009 07:11:58 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I've tried attaching a type-0 routing header to my IPv6 packets with
setsockopt(..., IPV6_RTHDR, ...), but the kernel just returns EINVAL.
looking at the source, it seems it simply refuses anything that's not type-2;
should that really be right? I found the following commit:

  http://kerneltrap.org/mailarchive/linux-netdev/2008/11/11/4064594

However, it only seems to change EPERM into EINVAL. I don't see any
reasonable explanation why it should not be simply success; in fact, RFC 3452
only seems to talk about using type-0 headers with this option.

Any ideas?

/* Steinar */
-- 
Homepage: http://www.sesse.net/
