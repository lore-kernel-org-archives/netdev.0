From: Andreas Petlund <apetlund@simula.no>
Subject: [net-next PATCH v5 0/3] net: TCP thin-stream latency-improving modifications
Date: Thu, 18 Feb 2010 13:42:13 +0100
Message-ID: <4B7D35A5.10106@simula.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: =?ISO-8859-1?Q?Ilpo_J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>,
	eric.dumazet@gmail.com, hannemann@nets.rwth-aachen.de,
	LKML <linux-kernel@vger.kernel.org>, shemminger@vyatta.com,
	william.allen.simpson@gmail.com, damian@tvk.rwth-aachen.de,
	ebiederm@xmission.com, David Miller <davem@davemloft.net>,
	Franco Fichtner <franco@lastsummer.de>
To: Netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-forward1.uio.no ([129.240.10.70]:50705 "EHLO
	mail-forward1.uio.no" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758104Ab0BRMmQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Feb 2010 07:42:16 -0500
Received: from exim by mail-out1.uio.no with local-bsmtp (Exim 4.69)
	(envelope-from <apetlund@simula.no>)
	id 1Ni5hv-0005nd-4Y
	for netdev@vger.kernel.org; Thu, 18 Feb 2010 13:42:15 +0100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a series of patches enabling non-intrusive, dynamically 
triggered modifications that improve retransmission latencies 
for thin streams.

The patch set was modified according to the feedback received.

Major change:
      -Used bitfields to compact the nonagle variable
       in the tcp_sock struct. nonagle, thin_lto and
       thin_dupack is now contained in the same u8.

I decided to use bitfields to handle this as it is
already done similarly in the tcp_options_received struct.

Also corrected some formatting issues.

Cheers,
Andreas Petlund
