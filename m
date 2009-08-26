From: Vitezslav Samel <vitezslav@samel.cz>
Subject: [BUG bisected] 2.6.30.4: NET: active FTP doesn't work
Date: Wed, 26 Aug 2009 10:33:59 +0200
Message-ID: <20090826083358.GB6010@pc11.op.pod.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Krzysztof Piotr Oledzki <ole@ans.pl>,
	Greg Kroah-Hartman <gregkh@suse.de>, netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from proxy.pod.cz ([213.155.227.133]:43732 "EHLO notes.pod.cz"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750867AbZHZIko (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 26 Aug 2009 04:40:44 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

	Hi!

  When testing 2.6.30.4+ kernel, I discovered active ftp does not work
anymore (2.6.30.3 is OK).

               LAN              internet
   machine1  -------  router1   -------   machine2


 Active ftp from machine1 to machine2 connects, transfers some files and
then hangs. Passive ftp works OK. The faulty box (router1)
is router/firewall and is doing NAT.

  I bisected it down to commit 7500f93f415a2fc07e0031d99fa3964bf8981cfc
in linux-2.6.30.y tree ("netfilter: tcp conntrack: fix unacknowledged
data detection with NAT").

  Could you, please, take look at it?

  I'm open to do any tests.

	Thanks,

		Vita Samel
