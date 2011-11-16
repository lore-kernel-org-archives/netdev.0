From: Matti Vaittinen <matti.vaittinen@nsn.com>
Subject: IPv6: Removing unnecessary NULL checks patch causes crash.
Date: Wed, 16 Nov 2011 11:51:59 +0200
Message-ID: <1321437119.1858.105.camel@hakki>
Reply-To: matti.vaittinen@nsn.com
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8BIT
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from demumfd001.nsn-inter.net ([93.183.12.32]:10435 "EHLO
	demumfd001.nsn-inter.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755464Ab1KPJkn convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Nov 2011 04:40:43 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I left my box to run some test scripts last night with net-next tree where patch
IPv6: Removing unnecessary NULL checks was applied. Crash had occurred when script 
executed "ip route change xxx/128 dev eth0" with non existing target twice 
in a row. (non existing target == there was no previous route to be changed) 

This was not occuring with kernel where only 
IPv6 routing, NLM_F_* flag support: REPLACE and EXCL flags support, warn about missing CREATE flag
and
IPv6 routing, NLM_F_* flag support: warn if new route is created without NLM_F_CREATE
were applied. 

Anyways, I cannot think how info struct could be NULL, so I am a bit
puzzled. Looks like I am missing some piece here. Anyways, somewhere in
these patches is lurking a bug. I try to find the reason. 

Sorry for the trouble.

--Matti

-- 
Matti Vaittinen
+358 504863070
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Told a UDP joke the other night...
...but I'm not sure everyone got it...
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
