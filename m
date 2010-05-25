From: Holger Freyther <zecke@selfish.org>
Subject: Question regarding =?utf-8?b?SVBfVE9T?= and =?utf-8?b?U09fUFJJT1JJVFk=?=
Date: Tue, 25 May 2010 21:19:32 +0000 (UTC)
Message-ID: <loom.20100525T230503-375@post.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from lo.gmane.org ([80.91.229.12]:35305 "EHLO lo.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758778Ab0EYVkF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 25 May 2010 17:40:05 -0400
Received: from list by lo.gmane.org with local (Exim 4.69)
	(envelope-from <linux-netdev-2@m.gmane.org>)
	id 1OH1r2-0007fN-9m
	for netdev@vger.kernel.org; Tue, 25 May 2010 23:40:04 +0200
Received: from fuckup.club.berlin.ccc.de ([195.160.172.2])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Tue, 25 May 2010 23:40:04 +0200
Received: from zecke by fuckup.club.berlin.ccc.de with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Tue, 25 May 2010 23:40:04 +0200
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all,

I have a minor question regarding the IP_TOS and SO_PRIORITY socket
options. I was reading the man page for ip(7) and it pointed me to
socket(7) to look at the SO_PRIORITY. My man page claims that setting
the SO_PRIORITY will also set the tos on the outgoing IP header.

The problem is that I couldn't see the TOS set in my outgoing packets
and I was not able to find the code propagating the sk_priority into the
tos. On the other hand I could find that setting the IP_TOS will also
set the sk_priority.

Is this a documentation bug? Or did it work once? Or is it working and
my code was just broken and I'm too blind to find it?

z.


