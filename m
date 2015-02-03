From: Reiner Herrmann <reiner.herrmann@sophos.com>
Subject: low vxlan throughput with tso enabled
Date: Tue, 3 Feb 2015 16:50:39 +0100
Message-ID: <bde634e5-3c57-4e80-9309-670cbd51c1b9@DE-WIE-EXCH3A.green.sophos>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <svens@stackframe.org>,
	Vittorio Curcio <Vittorio.Curcio@Sophos.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.sophos.com ([145.253.124.138]:60609 "EHLO mx2.sophos.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756010AbbBCP4Y (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Feb 2015 10:56:24 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi!

I have a vxlan tunnel established between two network interfaces, which
both have a MTU of 1500. The vxlan interfaces have the same MTU.
With TSO enabled, I observe low throughput with TCP connections (<100 kB/s).
Disabling TSO works around this issue and throughput is as expected.
Can someone please explain how TSO is influencing the tunnel to cause
such a difference?

Kind regards,
Reiner
