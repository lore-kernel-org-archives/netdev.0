From: Marcel Holtmann <marcel@holtmann.org>
Subject: protocol 0000 is buggy, dev nlmon
Date: Sun, 3 Aug 2014 11:05:26 -0700
Message-ID: <8CB882A0-240B-4759-A119-8867FCF70957@holtmann.org>
Mime-Version: 1.0 (Mac OS X Mail 7.3 \(1878.6\))
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: Network Development <netdev@vger.kernel.org>
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from senator.holtmann.net ([87.106.208.187]:53149 "EHLO
	mail.holtmann.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751383AbaHCSFS convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 3 Aug 2014 14:05:18 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Daniel,

when actually using nlmon, I get tons and tons of protocol xxxx is buggy warnings. Seems it misses setting the network_header correctly.

And on that note, I also found that we can not get the multicast group id from nlmon. This is something we should include to be able to distinguish where netlink messages are send to.

Regards

Marcel
