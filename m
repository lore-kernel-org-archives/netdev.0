From: "Beschorner Daniel" <Daniel.Beschorner@facton.com>
Subject: Invalid truesize messages since 2.6.25
Date: Tue, 22 Jul 2008 10:54:51 +0200
Message-ID: <3C59DB883F7B0B4D8096010D45ACCD13C73AFA@exch.facton.local>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from alpha.facton.com ([83.236.152.122]:37235 "EHLO alpha.facton.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752755AbYGVJPB convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Jul 2008 05:15:01 -0400
Received: from exch.facton.local (exch [192.168.200.5])
	by alpha.facton.com (8.13.8/8.13.8/FACTON) with ESMTP id m6M8spwa012730
	for <netdev@vger.kernel.org>; Tue, 22 Jul 2008 10:54:51 +0200
Content-class: urn:content-classes:message
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since 2.6.25 we rarely see these messages:

SKB BUG: Invalid truesize (408) len=198, sizeof(sk_buff)=216

Yesterday I saw it the first time after a runtime of one week with
2.6.26.
The box is web server / IPSEC gateway.
Obviously nothing seems to be affected by the message but <= 2.6.24 no
messages appeared.

Daniel
