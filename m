From: Henrique de Moraes Holschuh <hmh@hmh.eng.br>
Subject: [IPv6] kernel refuses to install blackhole routes without dev lo
Date: Tue, 25 Aug 2009 23:35:46 -0300
Message-ID: <20090826023546.GC14047@khazad-dum.debian.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out1.smtp.messagingengine.com ([66.111.4.25]:49744 "EHLO
	out1.smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756532AbZHZCfr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Aug 2009 22:35:47 -0400
Received: from compute2.internal (compute2.internal [10.202.2.42])
	by gateway1.messagingengine.com (Postfix) with ESMTP id 4B92C298B4
	for <netdev@vger.kernel.org>; Tue, 25 Aug 2009 22:35:49 -0400 (EDT)
Received: from khazad-dum.debian.net (unknown [201.82.70.134])
	by mail.messagingengine.com (Postfix) with ESMTPSA id EAFB415E98
	for <netdev@vger.kernel.org>; Tue, 25 Aug 2009 22:35:48 -0400 (EDT)
Received: from localhost (localhost [127.0.0.1])
	by localhost.khazad-dum.debian.net (Postfix) with ESMTP id B3ADD10003
	for <netdev@vger.kernel.org>; Tue, 25 Aug 2009 23:35:46 -0300 (BRT)
Received: from khazad-dum.debian.net ([127.0.0.1])
	by localhost (khazad-dum.debian.net [127.0.0.1]) (amavisd-new, port 10024)
	with LMTP id UVZvVoyq1SBW for <netdev@vger.kernel.org>;
	Tue, 25 Aug 2009 23:35:46 -0300 (BRT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

(Please keep me in the CC, I am not subscribed to netdev)

To make a long history short, and to get right to the point:

# ip -6 route add blackhole ::/0
RTNETLINK answers: No such device

while

# ip -6 route add blackhole ::/0 dev lo

and

# ip route add unreachable ::/0     

works just fine.  Looks like a bug, and it annoys the heck out of people
trying to use the standard way of null-routing on Quagga :-)

-- 
  "One disk to rule them all, One disk to find them. One disk to bring
  them all and in the darkness grind them. In the Land of Redmond
  where the shadows lie." -- The Silicon Valley Tarot
  Henrique Holschuh
