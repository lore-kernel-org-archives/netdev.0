From: Valerie Henson <val@nmt.edu>
Subject: [TULIP] Need new maintainer
Date: Mon, 30 Jul 2007 13:04:13 -0600
Message-ID: <20070730190412.GA16182@rainbow>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Grant Grundler <grundler@parisc-linux.org>,
	Jeff Garzik <jeff@garzik.org>
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	tulip-users@lists.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhost.nmt.edu ([129.138.4.52]:60457 "EHLO mailhost.nmt.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1763159AbXG3TEU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 30 Jul 2007 15:04:20 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The Tulip network driver needs a new maintainer!  I no longer have
time to maintain the Tulip network driver and I'm stepping down.  Jeff
Garzik would be happy to get volunteers.

The only current major outstanding patch I know of is Grant's shutdown
race patch, which was incorrectly dropped as obsoleted from -mm (my
fault, I was moving at the time):

http://www.mail-archive.com/mm-commits@vger.kernel.org/msg12161.html

I have a very much non-working patch to do it with the preferred
order, ask me for it and I'll see if I can dig it up.  It's unpleasant
partly because it pointed out a lot of latent bugs (e.g.,
del_timer_sync() in interrupt context).

Also, someone is working on support for an emulated Tulip card (yes,
Tulip will _never_ die), so expect possible patches for that.

-VAL
