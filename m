From: "Denys" <denys@visp.net.lb>
Subject: strange TCP behaviour
Date: Tue, 8 May 2007 12:49:36 +0300
Message-ID: <20070508094330.M22276@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain;
	charset=koi8-r
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from usermail.globalproof.net ([194.146.153.18]:39455 "EHLO
	usermail.globalproof.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934644AbXEHJuK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 May 2007 05:50:10 -0400
Received: from visp.net.lb (localhost [127.0.0.1])
	by usermail.globalproof.net (Postfix) with ESMTP id D0CB4BC7E7
	for <netdev@vger.kernel.org>; Tue,  8 May 2007 12:49:36 +0300 (EEST)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Dear All

I have application, thats accept redirected requests from squid (over iptables
... -j REDIRECT), getting ip over getsockopt/SO_ORIGINAL_DST and throwing data
in to the tunnel.

And i have strange behaviour, when i do
sysctl net.ipv4.tcp_frto=0

And i try any website with attachments (means a lot of data going to be sent
to redirect), i am getting after 3-10 seconds message "Read error: Connection
timed out". Thats a bit strange, possible it is related to application, but i
guess kernel must not give error to recv/read (i dont know what squid is
using). It is a bit difficult to reproduce the problem, but i can give a
remote access to PC where all things installed. But i have no idea, who of
TCP(?) maintainers can help me with this. I think there is no app problem,
tcpdump looks normal, there is no reset(and message will be different in case
of reset).


--
Denys Fedoryshchenko
Technical Manager
Virtual ISP S.A.L.

