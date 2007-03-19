From: Pekka Savola <pekkas@netcore.fi>
Subject: 2.6.20.3-rc1 / iproute2 hoplimit 2^32-1 vs 2^8-1
Date: Mon, 19 Mar 2007 17:11:41 +0200 (EET)
Message-ID: <Pine.LNX.4.64.0703191706530.3331@netcore.fi>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from netcore.fi ([193.94.160.1]:53289 "EHLO netcore.fi"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932419AbXCSPLn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 19 Mar 2007 11:11:43 -0400
Received: from localhost (pekkas@localhost)
	by netcore.fi (8.12.11.20060614/8.12.11) with ESMTP id l2JFBfkE003426
	for <netdev@vger.kernel.org>; Mon, 19 Mar 2007 17:11:41 +0200
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

On kernel based on 2.6.20.3-rc1 (FC6), 'ip -6 r l' shows:

default via fe80::212:f0ff:fe5f:c4ec dev eth1  proto kernel  metric 1024  expires 7191sec mtu 1500 advmss 1440 hoplimit 4294967295

(this is the same with iproute2-ss061214 and iproute2-ss070313.)

So, it seems that the data length for hoplimit is not quite right, or 
it's reported as 2^32-1 instead of 2^8-1...

-- 
Pekka Savola                 "You each name yourselves king, yet the
Netcore Oy                    kingdom bleeds."
Systems. Networks. Security. -- George R.R. Martin: A Clash of Kings
