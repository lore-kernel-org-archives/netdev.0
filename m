From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: e1000e "Detected Tx Unit Hang"
Date: Thu, 26 Jun 2008 08:52:53 +0800
Message-ID: <20080626005253.GA25316@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:44359 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754826AbYFZAw5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Jun 2008 20:52:57 -0400
Received: from gondolin.me.apana.org.au ([192.168.0.6] ident=mail)
	by arnor.apana.org.au with esmtp (Exim 4.63 #1 (Debian))
	id 1KBfjK-0007LS-H2
	for <netdev@vger.kernel.org>; Thu, 26 Jun 2008 10:52:54 +1000
Received: from herbert by gondolin.me.apana.org.au with local (Exim 3.36 #1 (Debian))
	id 1KBfjK-0006ak-00
	for <netdev@vger.kernel.org>; Thu, 26 Jun 2008 08:52:54 +0800
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi:

I'm getting these errors after upgrading to 2.6.26-rc8 (previously
running Red Hat's 2.6.18-53.el5xen which was stable):

Jun 26 08:26:16 gorgoroth kernel: eth0: Link is Up 1000 Mbps Full Duplex, Flow Control: RX/TX
Jun 26 08:27:28 gorgoroth kernel: eth0: TSO is Disabled
Jun 26 08:37:29 gorgoroth kernel: eth0: Detected Tx Unit Hang:
Jun 26 08:37:29 gorgoroth kernel:   TDH                  <ca>
Jun 26 08:37:29 gorgoroth kernel:   TDT                  <ce>
Jun 26 08:37:29 gorgoroth kernel:   next_to_use          <ce>
Jun 26 08:37:29 gorgoroth kernel:   next_to_clean        <c9>
Jun 26 08:37:29 gorgoroth kernel: buffer_info[next_to_clean]:
Jun 26 08:37:29 gorgoroth kernel:   time_stamp           <2d235>
Jun 26 08:37:29 gorgoroth kernel:   next_to_watch        <cb>
Jun 26 08:37:29 gorgoroth kernel:   jiffies              <2d49c>
Jun 26 08:37:29 gorgoroth kernel:   next_to_watch.status <0>
Jun 26 08:37:31 gorgoroth kernel: eth0: Detected Tx Unit Hang:
Jun 26 08:37:31 gorgoroth kernel:   TDH                  <ca>
Jun 26 08:37:31 gorgoroth kernel:   TDT                  <ce>
Jun 26 08:37:31 gorgoroth kernel:   next_to_use          <ce>
Jun 26 08:37:31 gorgoroth kernel:   next_to_clean        <c9>
Jun 26 08:37:31 gorgoroth kernel: buffer_info[next_to_clean]:
Jun 26 08:37:31 gorgoroth kernel:   time_stamp           <2d235>
Jun 26 08:37:31 gorgoroth kernel:   next_to_watch        <cb>
Jun 26 08:37:31 gorgoroth kernel:   jiffies              <2d690>
Jun 26 08:37:31 gorgoroth kernel:   next_to_watch.status <0>
Jun 26 08:37:32 gorgoroth kernel: NETDEV WATCHDOG: eth0: transmit timed out
Jun 26 08:37:34 gorgoroth kernel: eth0: Link is Up 1000 Mbps Full Duplex, Flow Control: RX/TX

This happens with or without TSO enabled.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
