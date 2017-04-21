From: bert hubert <bert.hubert@powerdns.com>
Subject: new documentation: IP_TRANSPARENT, is it correct?
Date: Fri, 21 Apr 2017 20:59:33 +0200
Message-ID: <20170421185933.GF4183@server.ds9a.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from tmpmail.powerdns.com ([128.199.32.142]:51156 "EHLO
        tmpmail.powerdns.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1424470AbdDUTGR (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 21 Apr 2017 15:06:17 -0400
Received: from localhost (localhost [127.0.0.1])
        by tmpmail.powerdns.com (Postfix) with ESMTP id 59CE96D937
        for <netdev@vger.kernel.org>; Fri, 21 Apr 2017 14:59:37 -0400 (EDT)
Received: from tmpmail.powerdns.com ([127.0.0.1])
        by localhost (tmpmail.powerdns.com [127.0.0.1]) (amavisd-new, port 10024)
        with ESMTP id cRSl_fG-JIkx for <netdev@vger.kernel.org>;
        Fri, 21 Apr 2017 14:59:36 -0400 (EDT)
Received: from server.ds9a.nl (unknown [IPv6:2001:470:1f15:bba::42])
        by tmpmail.powerdns.com (Postfix) with ESMTP id 729AF6D935
        for <netdev@vger.kernel.org>; Fri, 21 Apr 2017 14:59:36 -0400 (EDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi everyone,

10 years after lartc.org I decided to document a little bit more of Linux
networking, and I hope I got it right. This email asks for your help in
making sure.

Recently I attempted to use IP_TRANSPARENT as outlined in
https://www.kernel.org/doc/Documentation/networking/tproxy.txt but I could
not figure out how it really worked from there (although I could copy paste
my way to some working code).  The web also mostly offered little in the way
of (correct) explanation.

I think I have it figured out by now, but I'm sure there are nuances I have
missed. I'm especially interested in understanding _exactly_ what the
IP_TRANSPARENT socket option does, because it appears somewhat arbitrary
right now:

"The IP_TRANSPARENT socket option enables:

* Binding to addresses that are not (usually) considered local
* Receiving connections and packets from iptables TPROXY redirected sessions"

https://ds9a.nl/tproxy/tproxy.md.html has somewhat prettified Markdown that
requires Javascript, plain Markdown is on
https://github.com/ahupowerdns/tproxydoc/blob/master/tproxy.md

If you could give this a read and a comment on things I got wrong, that
would be most appreciated. Pointers to other relevant documentation are also
very welcome.

Thanks!

	Bert
	
