From: Daniel Slot <slot.daniel@gmail.com>
Subject: Re: [PATCH] net/ipv4, linux-2.6.30.4
Date: Fri, 14 Aug 2009 13:52:27 +0200
Message-ID: <bb6e06c00908140452t7e993282va5841a6dd4f2ba78@mail.gmail.com>
References: <bb6e06c00908121147h2dab7d0kf5841a40956c5c56@mail.gmail.com>
	 <20090812.145549.228391386.davem@davemloft.net>
	 <4A8409CA.70200@nets.rwth-aachen.de>
	 <20090813.131506.187121582.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: hannemann@nets.rwth-aachen.de, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f214.google.com ([209.85.219.214]:56234 "EHLO
	mail-ew0-f214.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754334AbZHNLw1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Aug 2009 07:52:27 -0400
Received: by ewy10 with SMTP id 10so1440666ewy.37
        for <netdev@vger.kernel.org>; Fri, 14 Aug 2009 04:52:27 -0700 (PDT)
In-Reply-To: <20090813.131506.187121582.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Why not just fix up for the deficiencies you're aware of?

Because it never was our intention to replace/improve the already
existing reordering mechanisms.
We just wanted to provide the possibility to switch to another
reordering-robust algorithm.
It could be similar to the large amount of congestion control
algorithms, which are also part of the kernel but rarely used.
A sophistcated congestion control algorithm is standardly used by the
kernel, but other ones are available too.

With our tcp-ncr patch, researchers would have the possibility to make
measurements with an IETF approved algorithm.
