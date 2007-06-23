From: Simon Arlott <simon@fire.lp0.eu>
Subject: Re: [RFD] First draft of RDNSS-in-RA support for IPv6 DNS autoconfiguration
Date: Sat, 23 Jun 2007 17:40:48 +0100
Message-ID: <467D4D10.20002@simon.arlott.org.uk>
References: <OF0D7F9D29.61F86942-ON88257303.0005AD2A-88257303.0005D48C@us.ibm.com>	 <200706231625.44825@auguste.remlab.net> <c6d9bea0706230747y79d39a6eh3c55de3a29cfb4d1@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: =?UTF-8?B?UsOpbWkgRGVuaXMtQ291cm1vbnQ=?= <rdenis@simphalempin.com>,
	David Stevens <dlstevens@us.ibm.com>, netdev@vger.kernel.org
To: "C. Scott Ananian" <cscott@laptop.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from proxima.lp0.eu ([85.158.45.36]:47796 "EHLO proxima.lp0.eu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754490AbXFWQk7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 23 Jun 2007 12:40:59 -0400
In-Reply-To: <c6d9bea0706230747y79d39a6eh3c55de3a29cfb4d1@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 23/06/07 15:47, C. Scott Ananian wrote:
> Advertisements it received.  I considered storing the *complete*
> Router Advertisement messages received and pushing them unparsed to
> userland, just to get around the bogus "DNS in the kernel" politics
> (hint: it's not a resolver in the kernel, it's just nameserver
> addresses being stored).  Does anyone really suggest that this would
> be a better solution?

Yes, but I don't think it should be completely unparsed - it should be
possible to retrieve the data for a specific attribute type with
expiration information and with notification of changes.

The kernel has to read RAs anyway, why shouldn't it store them in a way
that userspace can access it on demand? A /proc file which is in
resolv.conf format is definitely *wrong*, and while I'd argue for DNS
being special enough to export its attributes is it really too much to
have the kernel provide everything from the last valid message in a
partially parsed format? Applications would then parse the data section
for RA attributes they understand.

-- 
Simon Arlott
