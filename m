From: "Denys" <denys@visp.net.lb>
Subject: iproute2-2.6.20-070313 bug ?
Date: Wed, 21 Mar 2007 20:00:39 +0200
Message-ID: <20070321175951.M73913@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain;
	charset=koi8-r
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from usermail.globalproof.net ([194.146.153.18]:39157 "EHLO
	usermail.globalproof.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933306AbXCUSaB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Mar 2007 14:30:01 -0400
Received: from visp.net.lb (localhost [127.0.0.1])
	by usermail.globalproof.net (Postfix) with ESMTP id 18D7FBC726
	for <netdev@vger.kernel.org>; Wed, 21 Mar 2007 20:00:39 +0200 (EET)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Possible i discovered bug, but maybe specific to my setup. 

In your sources (tc/tc_core.h) i notice 
#define TIME_UNITS_PER_SEC    1000000000 
When i change it to 
#define TIME_UNITS_PER_SEC      1000000.0 
(it was value before in sources) 
everythign works fine. Otherwise tbf not working at all, it is dropping all 
packets.

Did anyone test new iproute2 with tbf?
--
Virtual ISP S.A.L.

