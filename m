From: Rusty Russell <rusty@rustcorp.com.au>
Subject: bne2 rx packet drop?
Date: Thu, 5 Aug 2010 08:59:57 +0930
Message-ID: <201008050859.57659.rusty@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Michael Chan <mchan@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:60341 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759439Ab0HDXaA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 Aug 2010 19:30:00 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Michael (and netdev!)

   I've got a customer seeing ~1000 rx packets dropped per day (on a busy
interface, bonding) via 'netstat -ni' RX-DRP's field across their 4-node
cluster.  The code seems to put checksum_discard and mac_discard into
that counter, so I'm not sure what the root cause is.

Any hints?  What are the conditions which cause mac_discard?

Thanks!
Rusty.
