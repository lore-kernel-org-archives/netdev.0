From: Andreas Petlund <apetlund@simula.no>
Subject: [net-next PATCH v4 0/3] net: TCP thin-stream latency-improving modifications
Date: Tue, 16 Feb 2010 15:40:18 +0100
Message-ID: <4B7AAE52.5050507@simula.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: =?ISO-8859-1?Q?Ilpo_J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Arnd Hannemann <hannemann@nets.rwth-aachen.de>,
	LKML <linux-kernel@vger.kernel.org>, shemminger@vyatta.com,
	David Miller <davem@davemloft.net>,
	william.allen.simpson@gmail.com, damian@tvk.rwth-aachen.de,
	"Eric W. Biederman" <ebiederm@xmission.com>
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-forward1.uio.no ([129.240.10.70]:56645 "EHLO
	mail-forward1.uio.no" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753870Ab0BPOkV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Feb 2010 09:40:21 -0500
Received: from exim by mail-out1.uio.no with local-bsmtp (Exim 4.69)
	(envelope-from <apetlund@simula.no>)
	id 1NhOb6-0001TA-Fo
	for netdev@vger.kernel.org; Tue, 16 Feb 2010 15:40:20 +0100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a series of patches enabling non-intrusive, dynamically triggered modifications that improve retransmission latencies for thin streams.

The patch set was modified according to the feedback received.

Major changes:
      -Renamed central variables, sysctls and ioctls.
      -Removed redundant allocations.
      -Added documentation in ip-sysctl.txt.
      -Added tcp thin-stream info in new file: tcp-thin.txt.

Cheers,
Andreas Petlund
