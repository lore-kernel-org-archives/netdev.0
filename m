From: Baruch Even <baruch@ev-en.org>
Subject: IPv6 source address selection
Date: Sun, 30 Jul 2006 15:05:57 +0100
Message-ID: <44CCBCC5.7070507@ev-en.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Ian McDonald <imcdnzl@gmail.com>,
	Linux Netdev List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rrcs-24-123-59-149.central.biz.rr.com ([24.123.59.149]:8029
	"EHLO galon.ev-en.org") by vger.kernel.org with ESMTP
	id S932319AbWG3OGD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 30 Jul 2006 10:06:03 -0400
To: YOSHIFUJI Hideaki <yoshfuji@kame.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

My network has several IPv6 addresses and they don't route between
themselves, due to the current source address selection it means that
many times the network is simply not operational since Linux will choose
an address for a different network than targeted for the connection.

I have seen in thread [1] that there is a patch for this and that
another patch was supposed to be applied for 2.6.15(!), yet I'm using
2.6.17 and nothing works.

Another report about this is at [2]

Could whatever difference exists be resolved and this issue fixed? IPv6
is completely unusable on my network due to this issue.

Thanks,
Baruch

[1] http://marc.theaimsgroup.com/?t=113045346500003&r=1&w=2
[2] http://marc.theaimsgroup.com/?l=linux-net&m=111989050303975&w=2
