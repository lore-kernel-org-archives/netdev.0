From: Jarek Poplawski <jarkao2@o2.pl>
Subject: Re: Endianness problem with u32 classifier hash masks
Date: Tue, 06 Nov 2007 01:12:54 +0100
Message-ID: <472FB186.9070503@o2.pl>
References: <1193939701.2987.82.camel@localhost.localdomain>	 <472B5EF1.4020206@o2.pl> <1194045830.4438.21.camel@localhost>	 <472D06B2.9040402@o2.pl> <472D0B1C.7000209@o2.pl> <472D128B.8030704@o2.pl>	 <472D1DC2.9000106@o2.pl> <1194220693.4438.75.camel@localhost>	 <20071105091231.GA1933@ff.dom.local>	 <1194267561.2987.141.camel@localhost.localdomain>	 <20071105135246.GB1933@ff.dom.local> <1194271589.4438.113.camel@localhost>	 <1194283888.2987.186.camel@localhost.localdomain>  <472F85F0.8060205@o2.pl> <1194301667.4430.28.camel@localhost> <472FAF29.7050704@o2.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: hadi@cyberus.ca, Radu Rendec <radu.rendec@ines.ro>,
	netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@o2.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx10.go2.pl ([193.17.41.74]:45750 "EHLO poczta.o2.pl"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753551AbXKFAA3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 Nov 2007 19:00:29 -0500
In-Reply-To: <472FAF29.7050704@o2.pl>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jarek Poplawski wrote, On 11/06/2007 01:02 AM:
...

> on little endian (net order):
> f0.0f.00.00 >> 4  gives: 0f.00.0f.00 then ntohl: 00.0f.00.0f with lsb: 0f

should be:
f0.0f.00.00 >> 4  gives: 0f.00.f0.00 then ntohl: 00.f0.00.0f with lsb: 0f

Jarek "Sleeping" P.
