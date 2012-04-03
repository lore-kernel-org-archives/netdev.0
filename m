From: Marc Kleine-Budde <mkl@blackshift.org>
Subject: stmmac: what happened to IFF_UNICAST_FLT
Date: Tue, 03 Apr 2012 13:14:55 +0200
Message-ID: <4F7ADBAF.1030204@blackshift.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	Giuseppe Cavallaro <peppe.cavallaro@st.com>
To: Rayagond Kokatanur <rayagond@vayavyalabs.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.186]:57616 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752894Ab2DCLPA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Apr 2012 07:15:00 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

I think in patch "bfab27a stmmac: add the experimental PCI support" the
flag IFF_UNICAST_FLT was lost, when the function
stmmac_mac_device_setup() was moved around.

regards, Marc
