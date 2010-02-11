From: Andreas Petlund <apetlund@simula.no>
Subject: [net-next PATCH v3 0/3] net: TCP thin-stream latency-improving modifications
Date: Thu, 11 Feb 2010 13:07:05 +0100
Message-ID: <4B73F2E9.3080306@simula.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: =?ISO-8859-1?Q?Ilpo_J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Arnd Hannemann <hannemann@nets.rwth-aachen.de>,
	LKML <linux-kernel@vger.kernel.org>, shemminger@vyatta.com,
	David Miller <davem@davemloft.net>,
	william.allen.simpson@gmail.com, damian@tvk.rwth-aachen.de
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-forward1.uio.no ([129.240.10.70]:33265 "EHLO
	mail-forward1.uio.no" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753151Ab0BKMHE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Feb 2010 07:07:04 -0500
Received: from exim by mail-out1.uio.no with local-bsmtp (Exim 4.69)
	(envelope-from <apetlund@simula.no>)
	id 1NfXp1-0006kk-3a
	for netdev@vger.kernel.org; Thu, 11 Feb 2010 13:07:03 +0100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a series of patches enabling non-intrusive, dynamically triggered modifications that improve retransmission latencies for thin streams.

The patches have been modified according to the feedback from the last round of discussions.

Major changes:
      -Possible to disable mechanisms by socket option
      -Socket option value boundary check

Cheers,
Andreas Petlund
