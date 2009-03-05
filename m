From: =?UTF-8?Q?=CE=86=CE=BB=CE=BA=CE=B7=CF=82_?=
	 =?UTF-8?Q?=CE=93=CE=B5=CF=89=CF=81=CE=B3=CF=8C=CF=80=CE=BF=CF=85=CE=BB?=
	 =?UTF-8?Q?=CE=BF=CF=82?= <alkisg@gmail.com>
Subject: r8169 - disable flow-control?
Date: Thu, 05 Mar 2009 21:35:43 +0200
Message-ID: <1236281743.10409.17.camel@alkisg>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f176.google.com ([209.85.220.176]:41520 "EHLO
	mail-fx0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756506AbZCETfr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Mar 2009 14:35:47 -0500
Received: by fxm24 with SMTP id 24so82894fxm.37
        for <netdev@vger.kernel.org>; Thu, 05 Mar 2009 11:35:45 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

Is there any way to disable flow control for NICs using the r8169
driver?

It would be really valuable in the following (sadly very common)
scenario:
 * r8169 gigabit NIC on the server
 * unmanaged gigabit switch that supports flow control negotiation
 * 100Mbps clients

E.g. in LTSP labs, the server can send data at ~900Mbps with flow
control off, but with flow control on the bandwidth drops to ~90Mbps.
Detailed explanation of the problem:
http://virtualthreads.blogspot.com/2006/02/beware-ethernet-flow-control.html

If the current code doesn't support it, would it be possible to add a
module parameter for this?

Kind regards,
Alkis Georgopoulos

