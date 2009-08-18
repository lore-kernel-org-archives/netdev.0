From: Roland Dreier <rdreier@cisco.com>
Subject: Re: mlx4 2.6.31-rc5: SW2HW_EQ failed.
Date: Tue, 18 Aug 2009 09:56:06 -0700
Message-ID: <adar5v912op.fsf@cisco.com>
References: <alpine.DEB.1.10.0908171523330.20399@gentwo.org>
	<ada7hx22j3g.fsf@cisco.com>
	<alpine.DEB.1.10.0908171814210.15956@gentwo.org>
	<ada3a7p3o6f.fsf@cisco.com>
	<alpine.DEB.1.10.0908181148460.3840@gentwo.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Yevgeny Petrilin <yevgenyp@mellanox.co.il>
To: Christoph Lameter <cl@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-2.cisco.com ([171.71.176.71]:45268 "EHLO
	sj-iport-2.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759406AbZHRQ4H (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Aug 2009 12:56:07 -0400
In-Reply-To: <alpine.DEB.1.10.0908181148460.3840@gentwo.org> (Christoph
	Lameter's message of "Tue, 18 Aug 2009 11:50:00 -0400 (EDT)")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


 > Never heard of device FW.

I just meant firmware running on the device (in this case the connectx adapter).

 > The Mellanox NIC has two ports. Could that be it?

No, the device is basically doing

	nreq = num_possible_cpus() + 1;
	pci_enable_msix(dev->pdev, entries, nreq);

(edited a bit but that's the code).  And nreq is ending up as 33 on your
box.

 > Will get back to you shortly when we have tested this patch.

Thanks.
