From: Emil Micek <emil.micek@tkrjasek.cz>
Subject: change the way e1000 is handling short VLAN frames
Date: Fri, 21 Sep 2007 09:31:45 +0200
Message-ID: <1190359905.3551.28.camel@magi.nadr>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from proxy-sec.valachnet.cz ([212.71.149.219]:45551 "EHLO
	proxy.valachnet.cz" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753572AbXIUIYh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Sep 2007 04:24:37 -0400
Received: from aula.nadr (pc10.valachnet.cz [212.71.186.10])
	by proxy.valachnet.cz (8.13.1/8.13.1) with ESMTP id l8L7Vjf9012355
	for <netdev@vger.kernel.org>; Fri, 21 Sep 2007 09:31:45 +0200
Received: from [192.168.1.242] ([192.168.1.242])
	(authenticated bits=0)
	by aula.nadr (8.13.1/8.13.1) with ESMTP id l8L7VjPU028302
	(version=TLSv1/SSLv3 cipher=RC4-MD5 bits=128 verify=NO)
	for <netdev@vger.kernel.org>; Fri, 21 Sep 2007 09:31:45 +0200
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello list,

I'd like to change behaviour of e1000 module when transmiting short
ethernet frames (shorter then 64 bytes) trough VLAN interface.

Current e1000 (according to our observations) first appends 4 bytes of
VLAN tag and then pads the frame to 64 bytes with zeroes if necessary
before transmiting it.

I'd like to change it so it first pads the frame to 64 B and appends the
VLAN tag afterwards, so the resulting VLAN frame would be 68 bytes
minimum.

I want to do it because C3 CMTS from arris, which is connected to our
linux box, has problems handling VLAN frames shorter then 68 bytes.

As i'm quite a newbie concerning linux sources and c programing, i'd
like to ask you if this'd be trivial or complex change and if someone
can point out relevant portions of the sources, where the necessary
changes should be done.

Regards

Emil Micek

