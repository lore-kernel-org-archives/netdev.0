From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [RFC] iproute2: split up ip man page?
Date: Wed, 7 Dec 2011 13:15:14 -0800
Message-ID: <20111207131514.6815f813@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:54554 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757907Ab1LGVPQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 7 Dec 2011 16:15:16 -0500
Received: from localhost (localhost.localdomain [127.0.0.1])
	by mail.vyatta.com (Postfix) with ESMTP id 3304E141005B
	for <netdev@vger.kernel.org>; Wed,  7 Dec 2011 13:15:16 -0800 (PST)
Received: from mail.vyatta.com ([127.0.0.1])
	by localhost (mail.vyatta.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id 3UJ-A56ZFtAs for <netdev@vger.kernel.org>;
	Wed,  7 Dec 2011 13:15:15 -0800 (PST)
Received: from nehalam.linuxnetplumber.net (static-50-53-80-93.bvtn.or.frontiernet.net [50.53.80.93])
	by mail.vyatta.com (Postfix) with ESMTPSA id 81B7C1410042
	for <netdev@vger.kernel.org>; Wed,  7 Dec 2011 13:15:15 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The current ip man page is both incomplete and so big that
the actual functions get lost easily.

I propose splitting the the pages for the subfunction
into sub pages. The man command appears
to be smart enough to handle:
  man tc htb

and pickup the manpage for /usr/share/man/man1/tc-htb.8.gz
Why not do the same thing for ip command?

The base ip page would just be a place holder that covered the
generic arguments.
