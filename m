From: "John A. Sullivan III" <jsullivan@opensourcedevel.com>
Subject: tc filter mask for ACK packets off?
Date: Sat, 31 Dec 2011 21:30:56 -0500
Message-ID: <1325385056.4174.51.camel@denise.theartistscloset.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.perfora.net ([74.208.4.194]:52267 "EHLO mout.perfora.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751033Ab2AACa7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 31 Dec 2011 21:30:59 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello, all.  I've been noticing that virtually all the documentation
says we should prioritize ACK only packets and that they can be
identified with match u8 0x10 0xff.  However, isn't the actual flag
field only 6 bits longs and the first two belong to a previous 6 bit
reserved field?
If that is true, if ever those bits are set, our filters will
unnecessarily break.  Shouldn't it be match u8 0x10 0x3f? Then again,
I'm very new at this.  Thanks - John
