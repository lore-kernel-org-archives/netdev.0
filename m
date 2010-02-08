From: Andreas Petlund <apetlund@simula.no>
Subject: [net-next PATCH v2 0/3] net: TCP thin-stream latency-improving modifications
Date: Mon, 08 Feb 2010 15:25:26 +0100
Message-ID: <4B701ED6.5000800@simula.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: =?ISO-8859-1?Q?Ilpo_J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Arnd Hannemann <hannemann@nets.rwth-aachen.de>,
	LKML <linux-kernel@vger.kernel.org>, shemminger@vyatta.com,
	David Miller <davem@davemloft.net>,
	william.allen.simpson@gmail.com
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-forward2.uio.no ([129.240.10.71]:37073 "EHLO
	mail-forward2.uio.no" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753139Ab0BHPEo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Feb 2010 10:04:44 -0500
Received: from exim by mail-out2.uio.no with local-bsmtp (Exim 4.69)
	(envelope-from <apetlund@simula.no>)
	id 1NeUXs-00056q-6p
	for netdev@vger.kernel.org; Mon, 08 Feb 2010 15:25:00 +0100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a series of patches enabling non-intrusive, dynamically triggered modifications that improves retransmission latencies for thin streams.

We have modified the patches according to the feedback from the last round of discussions.

Links to discussions about v1 of the patch set:
http://thread.gmane.org/gmane.linux.network/141394
http://thread.gmane.org/gmane.linux.network/141395
http://thread.gmane.org/gmane.linux.network/141396
http://thread.gmane.org/gmane.linux.network/141397

More information about the mechanics of the modifications, as well as extensive test results can be found here:
http://simula.no/research/nd/publications/Simula.nd.477/simula_pdf_file

Cheers,
Andreas Petlund


