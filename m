From: Bastian Bittorf <bittorf@bluebottle.com>
Subject: iproute2 / question: returncode when query a match
Date: Thu, 4 Jun 2015 10:16:38 +0200
Message-ID: <20150604081638.GI16021@medion.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.bluebottle.com ([176.9.67.91]:56596 "EHLO
	fe0.bluebottle.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752351AbbFDIOJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Jun 2015 04:14:09 -0400
Received: from localhost (p57AB122D.dip0.t-ipconnect.de [87.171.18.45])
	(using TLSv1.2 with cipher DHE-RSA-AES128-SHA (128/128 bits))
	(No client certificate requested)
	(Authenticated sender: bittorf@bluebottle.com)
	by fe0.bluebottle.com (Postfix) with ESMTPSA id D9B281EFBD
	for <netdev@vger.kernel.org>; Thu,  4 Jun 2015 08:07:20 +0000 (UTC)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

when executing e.g.:

root@box:~ ip route list exact '0.0.0.0/0'
default via 10.63.42.125 dev eth0.2  metric 2 onlink 
root@box:~ echo $?
0
root@box:~ ip route list exact '0.0.0.0/8'
root@box:~ echo $?
0

i expected an RC of != 0 when there is no match.
is this by design?

root@box:~ ip -V
ip utility, iproute2-ss4.0.0-1-openwrt

bye, bastian
